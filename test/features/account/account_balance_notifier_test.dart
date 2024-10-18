import 'package:didpay/features/account/account_balance.dart';
import 'package:didpay/features/account/account_balance_notifier.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/riverpod_helpers.dart';
import '../../helpers/test_data.dart';

Future<void> main() async {
  await TestData.initializeDids();

  final pfis = TestData.getPfis();
  final did = TestData.aliceDid;

  setUpAll(() {
    registerFallbackValue(
      const AsyncData<AccountBalance?>(null),
    );
  });

  group('AccountBalanceNotifier', () {
    group('fetchAccountBalance', () {
      test('should return null if pfis is empty', () async {
        final notifier = AccountBalanceNotifier();
        final result = await notifier.fetchAccountBalance(did, []);
        expect(result, null);
      });

      test('should return null if pfis is null', () async {
        final notifier = AccountBalanceNotifier();
        final result = await notifier.fetchAccountBalance(did, null);
        expect(result, null);
      });

      test('should set state to AsyncValue.data(accountBalance) if successful',
          () async {
        final mockTbdexService = MockTbdexService();
        final accountBalance = TestData.getAccountBalance();

        when(
          () => mockTbdexService.getAccountBalance(did, pfis),
        ).thenAnswer((_) async => accountBalance);

        final container = createContainer(
          overrides: [
            tbdexServiceProvider.overrideWith(
              (ref) => mockTbdexService,
            ),
          ],
        );

        final listener = Listener<AsyncValue<void>>();

        final accountBalanceNotifier =
            container.read(accountBalanceProvider.notifier);

        container.listen(accountBalanceProvider, listener.call);

        await accountBalanceNotifier.fetchAccountBalance(did, pfis);

        verify(
          () => listener(
            const AsyncLoading<AccountBalance?>(),
            any(that: isA<AsyncData<AccountBalance?>>()),
          ),
        );
      });

      test('should return account balance if successful', () async {
        final mockTbdexService = MockTbdexService();
        final accountBalance = TestData.getAccountBalance();

        when(
          () => mockTbdexService.getAccountBalance(did, pfis),
        ).thenAnswer((_) async => accountBalance);

        final container = createContainer(
          overrides: [
            tbdexServiceProvider.overrideWith(
              (ref) => mockTbdexService,
            ),
          ],
        );

        final accountBalanceNotifier =
            container.read(accountBalanceProvider.notifier);

        final result =
            await accountBalanceNotifier.fetchAccountBalance(did, pfis);

        expect(result, accountBalance);
      });

      test('should set state to AsyncValue.error when error occurs', () async {
        final mockTbdexService = MockTbdexService();

        when(
          () => mockTbdexService.getAccountBalance(did, pfis),
        ).thenThrow(Exception('Error fetching account balance'));

        final container = createContainer(
          overrides: [
            tbdexServiceProvider.overrideWith(
              (ref) => mockTbdexService,
            ),
          ],
        );

        final listener = Listener<AsyncValue<void>>();

        final accountBalanceNotifier =
            container.read(accountBalanceProvider.notifier);

        container.listen(accountBalanceProvider, listener.call);

        await accountBalanceNotifier.fetchAccountBalance(did, pfis);

        verify(
          () => listener(
            const AsyncLoading<AccountBalance?>(),
            any(that: isA<AsyncError>()),
          ),
        );
      });

      test('should return null when error occurs', () async {
        final mockTbdexService = MockTbdexService();

        when(
          () => mockTbdexService.getAccountBalance(did, pfis),
        ).thenThrow(Exception('Error fetching account balance'));

        final container = createContainer(
          overrides: [
            tbdexServiceProvider.overrideWith(
              (ref) => mockTbdexService,
            ),
          ],
        );

        final accountBalanceNotifier =
            container.read(accountBalanceProvider.notifier);

        final result =
            await accountBalanceNotifier.fetchAccountBalance(did, pfis);

        expect(result, null);
      });
    });
  });
}
