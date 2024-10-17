import 'dart:async';

import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/features/transaction/transaction_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/riverpod_helpers.dart';
import '../../helpers/test_data.dart';

void main() async {
  await TestData.initializeDids();

  final pfi = TestData.getPfi('did:dht:pfiDid');
  const exchangeId = 'rfq_01ha835rhefwmagsknrrhvaa0k';
  final parameters = TransactionProviderParameters(pfi, exchangeId);
  final did = TestData.aliceDid;

  setUpAll(() {
    registerFallbackValue(
      const AsyncData<Transaction?>(null),
    );
  });

  group('TransactionNotifier', () {
    test('should set the state to AsyncValue.data(transaction) on read',
        () async {
      final mockTbdexService = MockTbdexService();
      final exchange = TestData.getExchange();

      when(
        () => mockTbdexService.getExchange(
          did,
          pfi.did,
          exchangeId,
        ),
      ).thenAnswer((_) async => exchange);

      final container = createContainer(
        overrides: [
          didProvider.overrideWith(
            (ref) => did,
          ),
          tbdexServiceProvider.overrideWith(
            (ref) => mockTbdexService,
          ),
        ],
      );

      final listener = Listener<AsyncValue<void>>();

      final transactionProviderListenable = transactionProvider(parameters);

      container.listen(transactionProviderListenable, listener.call);

      await container.read(transactionProviderListenable.future);

      verify(
        () => listener(
          const AsyncLoading<Transaction?>(),
          any(that: isA<AsyncData<Transaction?>>()),
        ),
      );
    });

    test('should set the state to AsyncValue.error when error occurs',
        () async {
      final mockTbdexService = MockTbdexService();

      when(
        () => mockTbdexService.getExchange(
          did,
          pfi.did,
          exchangeId,
        ),
      ).thenThrow(Exception('Error fetching exchange'));

      final container = createContainer(
        overrides: [
          didProvider.overrideWith(
            (ref) => did,
          ),
          tbdexServiceProvider.overrideWith(
            (ref) => mockTbdexService,
          ),
        ],
      );

      final listener = Listener<AsyncValue<void>>();

      final transactionProviderListenable = transactionProvider(parameters);

      container.listen(transactionProviderListenable, listener.call);

      unawaited(await container.read(transactionProviderListenable.future));

      verify(
        () => listener(
          any(that: isA<AsyncError>()),
          const AsyncData<Transaction?>(null),
        ),
      );
    });
  });
}
