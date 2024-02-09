import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:web5_flutter/web5_flutter.dart';

class IdvService {
  Future<String> getWidgetUrl(String idvAuthRequestUrl) async {
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

    final jwtParts = request.split('.');
    final encodedClaims = jwtParts[1];

    Map<String, dynamic> decoded = json.fromBase64Url(encodedClaims);
    final responseUri = decoded['response_uri'];

    final idvResponse = await http.post(Uri.parse(responseUri),
        body: json.encode({
          'id_token': '123',
        }));

    Map<String, dynamic> decodedIdvResponse = json.decode(idvResponse.body);
    return decodedIdvResponse['url'];
  }
}
