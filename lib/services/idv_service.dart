import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:web5/web5.dart';

class IdvService {
  Future<String> getWidgetUrl(String idvAuthRequestUrl, BearerDid did) async {
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

    final decodedJwt = await Jwt.verify(request);

    final nonce = decodedJwt.claims.misc!['nonce'];
    final exp = nowEpochSeconds + tokenDuration.inSeconds;

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

    final idToken = await Jwt.sign(did: did, payload: claims);
    log('idToken: $idToken');

    final responseUri = decodedJwt.claims.misc!['response_uri'];
    final idvResponse = await http.post(Uri.parse(responseUri),
        body: json.encode({
          'idToken': idToken,
        }));

    Map<String, dynamic> decodedIdvResponse = json.decode(idvResponse.body);
    print(decodedIdvResponse);

    return Future.value('https://example.com');
  }
}
