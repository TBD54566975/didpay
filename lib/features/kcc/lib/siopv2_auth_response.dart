import 'package:didpay/features/kcc/lib/siopv2_auth_request.dart';
import 'package:web5/web5.dart';

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
