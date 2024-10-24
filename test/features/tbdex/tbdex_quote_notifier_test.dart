import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/tbdex/tbdex_quote_notifier.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/riverpod_helpers.dart';
import '../../helpers/test_data.dart';

Future<void> main() async {
  await TestData.initializeDids();

  final did = TestData.aliceDid;
  const pfiDid = '123';
  const exchangeId = 'rfq_01ha835rhefwmagsknrrhvaa0k';

  group('TbdexQuoteNotifier`', () {
    group('startPolling', () {
      test('should return Quote if successful', () async {
        final mockTbdexService = MockTbdexService();
        final quote = TestData.getQuote();

        when(() => mockTbdexService.getExchange(did, pfiDid, exchangeId))
            .thenAnswer((_) async => [quote]);

        final container = createContainer(
          overrides: [
            tbdexServiceProvider.overrideWith(
              (ref) => mockTbdexService,
            ),
            didProvider.overrideWith((ref) => did),
          ],
        );

        final tbdexQuoteNotifier = container.read(quoteProvider.notifier);

        final result =
            await tbdexQuoteNotifier.startPolling(pfiDid, exchangeId);

        expect(result, quote);
      });

      test('should throw an Exception if not successful', () async {
        final mockTbdexService = MockTbdexService();

        when(() => mockTbdexService.getExchange(did, pfiDid, exchangeId))
            .thenThrow(Exception('Error'));

        final container = createContainer(
          overrides: [
            tbdexServiceProvider.overrideWith(
              (ref) => mockTbdexService,
            ),
            didProvider.overrideWith((ref) => did),
          ],
        );

        final tbdexQuoteNotifier = container.read(quoteProvider.notifier);

        expect(
          () => tbdexQuoteNotifier.startPolling(pfiDid, exchangeId),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
