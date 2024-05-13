import 'dart:async';

import 'package:didpay/features/tbdex/transactions_notifier.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:tbdex/tbdex.dart';
import 'package:web5/web5.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockBearerDid extends Mock implements BearerDid {}

class MockTransactionsNotifier extends TransactionsAsyncNotifier {
  MockTransactionsNotifier() : super();

  @override
  FutureOr<List<Exchange>?> build() {
    return [];
  }

  @override
  Future<void> fetch() async {}
}
