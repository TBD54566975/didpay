import 'dart:async';

import 'package:didpay/features/account/account_balance.dart';
import 'package:didpay/features/account/account_balance_notifier.dart';
import 'package:didpay/features/feature_flags/feature_flag.dart';
import 'package:didpay/features/feature_flags/feature_flags_notifier.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/pfis/pfis_service.dart';
import 'package:didpay/features/tbdex/tbdex_quote_notifier.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/features/transaction/transaction_notifier.dart';
import 'package:didpay/features/vcs/vcs_notifier.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tbdex/tbdex.dart';
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

class MockVcsNotifier extends StateNotifier<List<String>>
    with Mock
    implements VcsNotifier {
  MockVcsNotifier(super.state);
}

class MockFeatureFlagsNotifier extends StateNotifier<List<FeatureFlag>>
    with Mock
    implements FeatureFlagsNotifier {
  MockFeatureFlagsNotifier(super.state);
}

class MockTransactionNotifier extends AutoDisposeFamilyAsyncNotifier<
    Transaction?,
    TransactionProviderParameters> with Mock implements TransactionNotifier {
  final Transaction? Function()? transactionBuilder;

  MockTransactionNotifier([this.transactionBuilder]);

  @override
  FutureOr<Transaction?> build(TransactionProviderParameters arg) async =>
      transactionBuilder?.call();
}

class MockTbdexQuoteNotifier extends AutoDisposeAsyncNotifier<Quote?>
    with Mock
    implements TbdexQuoteNotifier {
  MockTbdexQuoteNotifier();
}

class MockAccountBalanceNotifier
    extends AutoDisposeAsyncNotifier<AccountBalance?>
    with Mock
    implements AccountBalanceNotifier {
  final AccountBalance? accountBalance;

  MockAccountBalanceNotifier(this.accountBalance);

  @override
  FutureOr<AccountBalance?> build() async => accountBalance;
}

sealed class MockTransactionNotifierType {
  const MockTransactionNotifierType();
}

class MockTransactionNotifierWithData extends MockTransactionNotifierType {
  const MockTransactionNotifierWithData({required this.transactionType});

  final TransactionType transactionType;
}

class MockTransactionNotifierWithNullData extends MockTransactionNotifierType {
  const MockTransactionNotifierWithNullData();
}

class MockTransactionNotifierWithError extends MockTransactionNotifierType {
  const MockTransactionNotifierWithError();
}
