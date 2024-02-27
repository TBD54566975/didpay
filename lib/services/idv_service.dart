import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:web5/web5.dart';

class IdvService {
  Future<Map<String, dynamic>> getIdvRequest(
      String idvAuthRequestUrl, BearerDid did) async {
    // TODO: try/catch here
    final response = await http.get(Uri.parse(idvAuthRequestUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to load auth request');
    }

    // Parse the URI string so we can extract the query parameters
    Uri fakeUri = Uri.parse('https://example.com/?${response.body}');
    final request = fakeUri.queryParameters['request'];

    if (request == null) {
      throw Exception('Request not found');
    }

    final nowEpochSeconds = (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    const tokenDuration = Duration(minutes: 5);

    // TODO: try/catch here
    final decodedJwt = await Jwt.verify(request);

    // TODO: check for nonce here
    final nonce = decodedJwt.claims.misc!['nonce'];
    final exp = nowEpochSeconds + tokenDuration.inSeconds;

    // TODO: check for client_id here
    final claims = JwtClaims(
      iss: did.uri,
      aud: decodedJwt.claims.misc!['client_id'],
      sub: did.uri,
      exp: exp,
      iat: nowEpochSeconds,
      misc: {
        'nonce': nonce,
      },
    );

    // TODO: try/catch here
    final idToken = await Jwt.sign(did: did, payload: claims);
    log('id_token: $idToken');

    // TODO: check for response_uri here
    final responseUri = decodedJwt.claims.misc!['response_uri'];
    // TODO: try/catch here
    final idvResponse = await http.post(Uri.parse(responseUri),
        body: json.encode({
          'id_token': idToken,
        }));

    // TODO: try/catch here
    return json.decode(idvResponse.body);
  }
}
