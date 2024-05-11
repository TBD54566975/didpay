import 'dart:convert';

import 'package:didpay/features/kcc/idv_request.dart';
import 'package:didpay/features/kcc/oid4vc_exception.dart';
import 'package:didpay/features/kcc/siopv2.dart';
import 'package:didpay/features/kcc/token_request.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:web5/web5.dart';

final kccIssuanceServiceProvider = Provider((ref) => KccIssuanceService());

class KccIssuanceService {
  final http.Client httpClient;

  KccIssuanceService({http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  Future<IdvRequest> getIdvRequest(
    NuPfi pfi,
    BearerDid bearerDid,
  ) async {
    var response = await httpClient.get(pfi.idvServiceEndpoint);

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

    if (response.statusCode != 200) {
      throw Exception(
        'Sending siopv2 AuthResponse failed: ${response.statusCode} ${response.body}',
      );
    }

    return IdvRequest.fromJson(response.body);
  }

  /// Requests an access token from the PFI (aka KCC issuer) using the
  /// pre-authorized code from the IDV request.
  /// Info on the request being sent can be found [here](https://openid.github.io/OpenID4VCI/openid-4-verifiable-credential-issuance-wg-draft.html#name-token-endpoint)
  Future<TokenResponse> getAccessToken(NuPfi pfi, IdvRequest idvRequest) async {
    //! TODO: replace this hardcoded endpoint with a request to well-known
    //! metadata endpoint to get actual endpoint
    final tokenEndpoint =
        pfi.idvServiceEndpoint.replace(path: '/ingress/oidc/token');

    final tokenRequest = TokenRequest(
      preAuthCode: idvRequest.credentialOffer.preAuthorizedCode,
      grantType: idvRequest.credentialOffer.grantType,
      clientId: pfi.did.uri,
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

    response = await httpClient.post(
      tokenEndpoint,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(tokenRequest.toMap()),
    );

    if (response.statusCode == 200) {
      try {
        return TokenResponse.fromJson(response.body);
      } on Exception catch (e) {
        throw TokenResponseException(
          message: 'failed to parse response body',
          status: response.statusCode,
          cause: e,
          body: response.body,
        );
      }
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      OID4VCErrorResponse errorResp;
      try {
        errorResp = OID4VCErrorResponse.fromJson(response.body);
      } on Exception catch (e) {
        throw TokenResponseException(
          message: 'failed to parse error response',
          status: response.statusCode,
          cause: e,
          body: response.body,
        );
      }

      throw OID4VCException.fromErrorResponse(errorResp);
    } else {
      throw TokenResponseException(
        message: 'unexpected response status',
        status: response.statusCode,
        body: response.body,
      );
    }
  }

  Future<void> getVerifiableCredential(NuPfi pfi, TokenResponse tokenResponse) {
    throw UnimplementedError();
  }
}
