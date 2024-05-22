import 'dart:async';

import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/pfis/pfis_service.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/tbdex/transaction_notifier.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web5/web5.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockBearerDid extends Mock implements BearerDid {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockPfisService extends Mock implements PfisService {}

class MockTbdexService extends Mock implements TbdexService {}

class MockTransactionNotifier extends TransactionAsyncNotifier {
  MockTransactionNotifier() : super();

  @override
  FutureOr<Transaction?> build(TransactionProviderParameters arg) {
    return null;
  }

  @override
  Future<void> startPolling() {
    return Future.value();
  }
}

class MockPfisNotifier extends PfisNotifier {
  MockPfisNotifier()
      : super(
          MockSharedPreferences(),
          MockPfisService(),
          [const Pfi(did: 'did:web:x%3A8892:ingress')],
        );
}
