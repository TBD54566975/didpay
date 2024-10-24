import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/tbdex/tbdex_order_instructions_notifier.dart';
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

  group('TbdexOrderInstructionsNotifier`', () {
    group('startPolling', () {
      test('should return OrderInstructions if successful', () async {
        final mockTbdexService = MockTbdexService();
        final orderInstruction = TestData.getOrderInstructions();

        when(() => mockTbdexService.getExchange(did, pfiDid, exchangeId))
            .thenAnswer((_) async => [orderInstruction]);

        final container = createContainer(
          overrides: [
            tbdexServiceProvider.overrideWith(
              (ref) => mockTbdexService,
            ),
            didProvider.overrideWith((ref) => did),
          ],
        );

        final tbdexOrderInstructionsNotifier =
            container.read(orderInstructionsProvider.notifier);

        final result = await tbdexOrderInstructionsNotifier.startPolling(
          pfiDid,
          exchangeId,
        );

        expect(result, orderInstruction);
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

        final tbdexOrderInstructionsNotifier =
            container.read(orderInstructionsProvider.notifier);

        expect(
          () => tbdexOrderInstructionsNotifier.startPolling(
            pfiDid,
            exchangeId,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
