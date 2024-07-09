import 'dart:convert';

import 'package:didpay/features/kcc/lib.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';
import 'package:web5/web5.dart';

final kccIssuanceProvider = Provider((_) => KccIssuanceService());

class KccIssuanceService {
  final http.Client httpClient;

  KccIssuanceService({http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  Future<Uri> getTokenEndpoint(CredentialOffer credentialOffer) async {
    final issuerUrl = credentialOffer.credentialIssuerUrl;
    final authorizationMetadataEndpoint = issuerUrl.replace(
      path: '${issuerUrl.path}/.well-known/oauth-authorization-server',
    );

    http.Response response;
    try {
      response = await httpClient.get(authorizationMetadataEndpoint);
    } on Exception catch (e) {
      throw AuthorizationMetadataRequestException(
        message: 'failed to send authorization metadata request to $issuerUrl',
        cause: e,
      );
    }

    if (response.statusCode == 200) {
      try {
        final authzMetadata = AuthorizationMetadata.fromJson(response.body);

        return authzMetadata.tokenEndpoint;
      } on Exception catch (e) {
        throw AuthorizationMetadataResponseException(
          message: 'failed to parse response body',
          status: response.statusCode,
          cause: e,
          body: response.body,
        );
      }
    } else {
      throw AuthorizationMetadataResponseException(
        message: 'unexpected response status',
        status: response.statusCode,
        body: response.body,
      );
    }
  }

  Future<IssuerMetadata> getIssuerMetadata(
    CredentialOffer credentialOffer,
  ) async {
    final issuerUrl = credentialOffer.credentialIssuerUrl;
    final issuerMetadataEndpoint = issuerUrl.replace(
      path: '${issuerUrl.path}/.well-known/openid-credential-issuer',
    );

    http.Response response;
    try {
      response = await httpClient.get(issuerMetadataEndpoint);
    } on Exception catch (e) {
      throw IssuerMetadataRequestException(
        message: 'failed to send authorization metadata request to $issuerUrl',
        cause: e,
      );
    }

    if (response.statusCode == 200) {
      try {
        return IssuerMetadata.fromJson(response.body);
      } on Exception catch (e) {
        throw IssuerMetadataResponseException(
          message: 'failed to parse response body',
          status: response.statusCode,
          cause: e,
          body: response.body,
        );
      }
    } else {
      throw IssuerMetadataResponseException(
        message: 'unexpected response status',
        status: response.statusCode,
        body: response.body,
      );
    }
  }

  Future<IdvRequest> getIdvRequest(
    Pfi pfi,
    BearerDid bearerDid,
  ) async {
    final idvServiceEndpoint = await getIdvServiceEndpoint(pfi);
    var response = await httpClient.get(idvServiceEndpoint);

    final authRequest = await SiopV2AuthRequest.fromUrlParams(response.body);
    final authResponse = await SiopV2AuthResponse.fromRequest(
      authRequest,
      bearerDid,
    );

    response = await httpClient.post(
      authRequest.responseUri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(authResponse.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return IdvRequest.fromJson(response.body);
    }

    throw Exception(
      'Sending siopv2 AuthResponse failed: ${response.statusCode} ${response.body}',
    );
  }

  /// Requests an access token from the PFI (aka KCC issuer) using the
  /// pre-authorized code from the IDV request.
  ///
  /// [Reference](https://openid.github.io/OpenID4VCI/openid-4-verifiable-credential-issuance-wg-draft.html#name-token-endpoint)
  Future<TokenResponse> getAccessToken(
    Pfi pfi,
    IdvRequest idvRequest,
    BearerDid bearerDid,
  ) async {
    final tokenEndpoint = await getTokenEndpoint(idvRequest.credentialOffer);

    final tokenRequest = TokenRequest(
      preAuthCode: idvRequest.credentialOffer.preAuthorizedCode,
      grantType: idvRequest.credentialOffer.grantType,
      clientId: bearerDid.uri,
    );

    http.Response response;
    try {
      response = await httpClient.post(
        tokenEndpoint,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(tokenRequest.toMap()),
      );
    } on Exception catch (e) {
      throw TokenRequestException(
        message: 'failed to send token request',
        cause: e,
      );
    }

    if (response.statusCode == 200) {
      try {
        return TokenResponse.fromJson(response.body);
      } on Exception catch (e) {
        throw TokenUnknownResponseException(
          message: 'failed to parse response body',
          status: response.statusCode,
          cause: e,
          body: response.body,
        );
      }
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      TokenErrorResponse errorResp;
      try {
        errorResp = TokenErrorResponse.fromJson(response.body);
      } on Exception catch (e) {
        throw TokenUnknownResponseException(
          message: 'failed to parse error response',
          status: response.statusCode,
          cause: e,
          body: response.body,
        );
      }

      throw TokenResponseException.fromErrorResponse(errorResp);
    } else {
      throw TokenUnknownResponseException(
        message: 'unexpected response status',
        status: response.statusCode,
        body: response.body,
      );
    }
  }

  Future<CredentialResponse> getVerifiableCredential(
    Pfi pfi,
    IdvRequest idvRequest,
    TokenResponse tokenResponse,
    BearerDid bearerDid,
  ) async {
    // create proof jwt per https://openid.github.io/OpenID4VCI/openid-4-verifiable-credential-issuance-wg-draft.html#section-7.2.1.1
    final proofClaims = JwtClaims(
      aud: pfi.did,
      iss: bearerDid.uri,
      iat: DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000,
      misc: {'nonce': tokenResponse.cNonce},
    );

    String proofJwt;
    try {
      proofJwt = await Jwt.sign(
        did: bearerDid,
        payload: proofClaims,
        type: 'openid4vci-proof+jwt',
      );
    } on Exception catch (e) {
      throw CredentialRequestException(
        message: 'failed to sign proof jwt',
        cause: e,
      );
    }

    // TODO(mistermoe): check for tokenResponse.credential_identifiers before setting format
    final credentialRequest = CredentialRequest(
      format: 'jwt_vc_json',
      proof: ProofJwt(jwt: proofJwt),
    );

    late http.Response response;

    final issuerMetadata = await getIssuerMetadata(idvRequest.credentialOffer);

    try {
      response = await httpClient.post(
        issuerMetadata.credentialEndpoint,
        headers: {
          'Authorization': 'Bearer ${tokenResponse.accessToken}',
          'Content-Type': 'application/json',
        },
        body: credentialRequest.toJson(),
      );
    } on Exception catch (e) {
      throw CredentialRequestException(
        message: 'failed to send credential request',
        cause: e,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return CredentialResponse.fromJson(response.body);
      } on Exception catch (e) {
        throw CredentialUnknownResponseException(
          message: 'failed to parse response body',
          status: response.statusCode,
          cause: e,
          body: response.body,
        );
      }
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      CredentialErrorResponse errorResp;
      try {
        errorResp = CredentialErrorResponse.fromJson(response.body);
      } on Exception catch (e) {
        throw CredentialUnknownResponseException(
          message: 'failed to parse error response',
          status: response.statusCode,
          cause: e,
          body: response.body,
        );
      }

      throw CredentialResponseException.fromErrorResponse(errorResp);
    } else {
      throw CredentialUnknownResponseException(
        message: 'unexpected response status',
        status: response.statusCode,
        body: response.body,
      );
    }
  }

  /// used to receive a Credential previously requested using [getVerifiableCredential]
  /// in cases where the Credential Issuer was not able to immediately issue the
  /// Credential. Support for this endpoint is OPTIONAL.
  ///
  /// [Reference](https://openid.github.io/OpenID4VCI/openid-4-verifiable-credential-issuance-wg-draft.html#section-9)
  Future<CredentialResponse> getDeferredVerifiableCredential(
    Pfi pfi,
    IdvRequest idvRequest,
    TokenResponse tokenResponse,
    CredentialResponse previousCredentialResponse,
    BearerDid bearerDid,
  ) async {
    if (previousCredentialResponse.transactionId == null) {
      throw DeferredCredentialRequestException(
        message: 'previous credential response does not have transaction id',
      );
    }

    // TODO(mistermoe): Get Issuer metadata to get deferred credential endpoint
    final deferredCredentialEndpoint = Uri.parse(
      'https://example.com/deferred-credential-endpoint',
    );

    final deferredCredentialRequest = DeferredCredentialRequest(
      transactionId: previousCredentialResponse.transactionId!,
    );

    http.Response response;
    try {
      response = await httpClient.post(
        deferredCredentialEndpoint,
        headers: {
          'Authorization': 'Bearer ${tokenResponse.accessToken}',
          'Content-Type': 'application/json',
        },
        body: deferredCredentialRequest.toJson(),
      );
    } on Exception catch (e) {
      throw DeferredCredentialRequestException(
        message: 'failed to send deferred credential request',
        cause: e,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return CredentialResponse.fromJson(response.body);
      } on Exception catch (e) {
        throw DeferredCredentialUnknownResponseException(
          message: 'failed to parse response body',
          status: response.statusCode,
          cause: e,
          body: response.body,
        );
      }
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      DeferredCredentialErrorResponse errorResp;
      try {
        errorResp = DeferredCredentialErrorResponse.fromJson(response.body);
      } on Exception catch (e) {
        throw DeferredCredentialUnknownResponseException(
          message: 'failed to parse error response',
          status: response.statusCode,
          cause: e,
          body: response.body,
        );
      }

      throw DeferredCredentialResponseException.fromErrorResponse(errorResp);
    } else {
      throw DeferredCredentialUnknownResponseException(
        message: 'unexpected response status',
        status: response.statusCode,
        body: response.body,
      );
    }
  }

  Future<CredentialResponse> pollForCredential(
    Pfi pfi,
    IdvRequest idvRequest,
    BearerDid bearerDid,
  ) async {
    final tokenResponse = await retry(
      () => getAccessToken(pfi, idvRequest, bearerDid),
      retryIf: (e) {
        if (e is TokenResponseException) {
          return e.errorCode == TokenResponseErrorCode.authorizationPending;
        }
        return false;
      },
    );

    return getVerifiableCredential(pfi, idvRequest, tokenResponse, bearerDid);
  }

  Future<Uri> getIdvServiceEndpoint(Pfi pfi) async {
    try {
      final res = await DidResolver.resolve(pfi.did);
      if (res.hasError()) {
        throw Exception(
          'Failed to resolve PFI DID: ${res.didResolutionMetadata.error}',
        );
      }

      if (res.didDocument == null) {
        throw Exception('Malformed resolution result: missing DID Document');
      }

      return PfisService.getServiceEndpoint(res.didDocument!, 'IDV');
    } on Exception catch (e) {
      throw CredentialRequestException(
        message: 'failed to resolve PFI DID',
        cause: e,
      );
    }
  }
}
