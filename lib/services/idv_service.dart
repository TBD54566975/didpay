import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web5/web5.dart';

class IdvService {
  static const _expirationDuration = Duration(minutes: 5);

  Future<String> getIdvRequest(String idvAuthRequestUrl, BearerDid did) async {
    final decodedJwt = await getAuthRequest(idvAuthRequestUrl);

    final nonce = decodedJwt.claims.misc?['nonce'] ??
        (throw Exception('Nonce not found'));
    final clientId = decodedJwt.claims.misc?['client_id'] ??
        (throw Exception('Client ID not found'));
    final responseUri = decodedJwt.claims.misc?['response_uri'] ??
        (throw Exception('Response URI not found'));

    final idToken = await _computeIdToken(did, clientId, nonce);
    final authResponse = await _postAuthResponse(responseUri, idToken);

    final idvUrl =
        authResponse['url'] ?? (throw Exception('IDV request missing url'));

    return idvUrl;
  }

  Future<DecodedJwt> getAuthRequest(String idvAuthRequestUrl) async {
    final response = await http.get(Uri.parse(idvAuthRequestUrl));

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to load auth request with status code: ${response.statusCode}');
    }

    final queryParameters = await _getQueryParameters(response);
    final authRequest = queryParameters['request'] ??
        (throw Exception('Auth request not found'));

    final decodedJwt = await _decodeJwt(authRequest);

    return decodedJwt;
  }

  Future<Map<String, String>> _getQueryParameters(
      http.Response response) async {
    try {
      return Uri.splitQueryString(response.body);
    } catch (e) {
      throw Exception('Error getting query parameters: $e');
    }
  }

  Future<DecodedJwt> _decodeJwt(String jwt) async {
    try {
      return await Jwt.verify(jwt);
    } catch (e) {
      throw Exception('Error decoding JWT: $e');
    }
  }

  Future<String> _computeIdToken(
      BearerDid did, String clientId, String nonce) async {
    try {
      final nowEpochSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final exp = nowEpochSeconds + _expirationDuration.inSeconds;

      final claims = JwtClaims(
        iss: did.uri,
        aud: clientId,
        sub: did.uri,
        exp: exp,
        iat: nowEpochSeconds,
        misc: {
          'nonce': nonce,
        },
      );

      return await Jwt.sign(did: did, payload: claims);
    } catch (e) {
      throw Exception('Error computing ID token: $e');
    }
  }

  Future<Map<String, dynamic>> _postAuthResponse(
      String uri, String idToken) async {
    try {
      final authResponse = await http.post(
        Uri.parse(uri),
        body: json.encode(
          {
            'id_token': idToken,
          },
        ),
      );

      if (authResponse.statusCode != 200) {
        throw Exception(
            'Failed to send auth response with status code: ${authResponse.statusCode}');
      }

      return json.decode(authResponse.body);
    } catch (e) {
      throw Exception('Error getting idv request: $e');
    }
  }
}
