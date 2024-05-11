import 'dart:convert';

import 'package:web5/web5.dart';

/// Represents a Self-Issued OpenID Provider (SIOPv2) Authorization Request.
/// See [here](https://openid.net/specs/openid-connect-self-issued-v2-1_0.html#section-5-5)
class SiopV2AuthRequest {
  final String nonce;
  final String clientId;
  final Uri responseUri;

  SiopV2AuthRequest({
    required this.nonce,
    required this.clientId,
    required this.responseUri,
  });

  /// Parses a SiopV2AuthRequest from a URL query string.
  /// Example [here](https://openid.net/specs/openid-connect-self-issued-v2-1_0.html#section-5-5)
  static Future<SiopV2AuthRequest> fromUrlParams(String queryParams) async {
    final authRequestParams = Uri.splitQueryString(queryParams);
    if (!authRequestParams.containsKey('request')) {
      throw Exception();
    }

    // per https://www.rfc-editor.org/rfc/rfc9101.html
    final decodedRequestJwt = await Jwt.verify(authRequestParams['request']!);

    return SiopV2AuthRequest.fromMap(decodedRequestJwt.claims.misc!);
  }

  factory SiopV2AuthRequest.fromJson(String input) {
    final data = jsonDecode(input);
    return SiopV2AuthRequest.fromMap(data);
  }

  factory SiopV2AuthRequest.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('nonce')) {
      throw ArgumentError('Missing required key: nonce');
    }
    if (!map.containsKey('client_id')) {
      throw ArgumentError('Missing required key: client_id');
    }
    if (!map.containsKey('response_uri')) {
      throw ArgumentError('Missing required key: response_uri');
    }

    return SiopV2AuthRequest(
      nonce: map['nonce']!,
      clientId: map['client_id']!,
      responseUri: Uri.parse(map['response_uri']!),
    );
  }
}

/// Represents a Self-Issued OpenID Provider (SIOPv2) Authorization Response.
/// See [here](https://openid.net/specs/openid-connect-self-issued-v2-1_0.html#name-self-issued-openid-provider-au)
class SiopV2AuthResponse {
  final String idToken;

  SiopV2AuthResponse({required this.idToken});

  static const jwtExpiration = Duration(minutes: 5);
  static Future<SiopV2AuthResponse> fromRequest(
    SiopV2AuthRequest request,
    BearerDid did,
  ) async {
    final nowEpochSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final claims = JwtClaims(
      iss: did.uri,
      aud: request.clientId,
      sub: did.uri,
      exp: nowEpochSeconds + jwtExpiration.inSeconds,
      iat: nowEpochSeconds,
      misc: {'nonce': request.nonce},
    );

    final idToken = await Jwt.sign(did: did, payload: claims);

    return SiopV2AuthResponse(idToken: idToken);
  }

  Map<String, dynamic> toJson() {
    return {
      'id_token': idToken,
    };
  }
}
