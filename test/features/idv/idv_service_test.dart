import 'package:didpay/features/idv/idv_service.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:mocktail/mocktail.dart';
import 'package:web5/web5.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockHttpClient mockHttpClient;
  late IdvService subject;

  setUp(() {
    mockHttpClient = MockHttpClient();
    subject = IdvService(httpClient: mockHttpClient);
  });

  group('IdvService', () {
    test('should get IDV request', () async {
      final uri = Uri.parse('http://idv.com');
      final uri2 = Uri.parse('response_uri');
      final bearerDid = await DidDht.create(publish: true);
      final jwtClaims = JwtClaims(
        iss: 'did:example:123',
        aud: 'clientId',
        sub: 'did:example:123',
        exp: 1,
        iat: 2,
        misc: {
          'client_id': 's.ClientID',
          'nonce': 's.Nonce',
          'response_uri': 'response_uri',
        },
      );
      final jwt = await Jwt.sign(did: bearerDid, payload: jwtClaims);
      when(() => mockHttpClient.get(uri))
          .thenAnswer((_) async => http.Response('request=$jwt', 200));
      when(() => mockHttpClient.post(uri2, body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('{"url": "123"}', 200));

      final result = await subject.getIdvRequest('http://idv.com', bearerDid);
      expect(result, '123');
      verify(() => mockHttpClient.get(Uri.parse('http://idv.com')));
    });
  });
}
