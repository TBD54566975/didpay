import 'dart:async';

import 'package:didpay/features/countries/countries.dart';
import 'package:didpay/features/countries/countries_notifier.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/pfis/pfis_service.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/tbdex/transaction_notifier.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:web5/web5.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockBearerDid extends Mock implements BearerDid {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockPfisService extends Mock implements PfisService {}

class MockTbdexService extends Mock implements TbdexService {}

class MockBox extends Mock implements Box {}

class MockPfisNotifier extends StateNotifier<List<Pfi>>
    with Mock
    implements PfisNotifier {
  MockPfisNotifier(super.state);
}

class MockCountriesNotifier extends StateNotifier<List<Country>>
    with Mock
    implements CountriesNotifier {
  MockCountriesNotifier(super.state);
}

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
