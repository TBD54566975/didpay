import 'dart:async';

import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/pfis/pfis_service.dart';
import 'package:didpay/features/tbdex/transactions_notifier.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbdex/tbdex.dart';
import 'package:web5/web5.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockBearerDid extends Mock implements BearerDid {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockPfisService extends Mock implements PfisService {}

class MockTransactionsNotifier extends TransactionsAsyncNotifier {
  MockTransactionsNotifier() : super();

  @override
  FutureOr<List<Exchange>?> build() {
    return [];
  }

  @override
  Future<void> fetch() async {}
}

class MockPfisNotifier extends PfisNotifier {
  MockPfisNotifier()
      : super(MockSharedPreferences(), MockPfisService(), [
          Pfi(
            did: 'did:web:x%3A8892:ingress',
            tbdexServiceEndpoint: Uri.parse('http://x:8892/ingress/idv'),
            idvServiceEndpoint: Uri.parse('http://x:8892/ingress/pfi'),
          )
        ]);
}
