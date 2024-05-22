import 'dart:async';
import 'dart:convert';

import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/storage/storage_service.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final transactionAsyncProvider = AsyncNotifierProvider.family.autoDispose<
    ExchangeAsyncNotifier, Transaction?, TransactionProviderParameters>(
  ExchangeAsyncNotifier.new,
);

final transactionStateProvider =
    StateNotifierProvider.family<TransactionNotifier, Transaction?, String>(
  (ref, id) {
    final sharedPreferences = ref.read(sharedPreferencesProvider);
    return TransactionNotifier(id, sharedPreferences);
  },
);

class ExchangeAsyncNotifier extends AutoDisposeFamilyAsyncNotifier<Transaction?,
    TransactionProviderParameters> {
  late String? _exchangeId;
  late Pfi? _pfi;
  Timer? _timer;

  @override
  FutureOr<Transaction?> build(TransactionProviderParameters arg) async {
    _exchangeId = arg.exchangeId;
    _pfi = arg.pfi;
    return fetchExchange();
  }

  Future<Transaction?> fetchExchange() async {
    if (_pfi == null || _exchangeId == null) return null;

    try {
      final bearerDid = ref.read(didProvider);
      final tbdexService = ref.read(tbdexServiceProvider);
      final exchange =
          await tbdexService.getExchange(bearerDid, _pfi!, _exchangeId!);

      final transaction = Transaction.fromExchange(exchange);

      await TransactionNotifier(
        arg.exchangeId,
        ref.read(sharedPreferencesProvider),
      ).add(transaction);

      if (transaction.status == TransactionStatus.payoutCanceled ||
          transaction.status == TransactionStatus.payoutSuccess) {
        stopPolling();
      }

      state = AsyncValue.data(transaction);
      return transaction;
    } on Exception catch (e) {
      state = AsyncValue.error(
        e,
        StackTrace.current,
      );
    }
    return null;
  }

  void startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) => fetchExchange(),
    );
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }
}

class TransactionNotifier extends StateNotifier<Transaction?> {
  static const String prefsKey = 'txn_';

  final String exchangeId;
  final SharedPreferences prefs;

  TransactionNotifier(this.exchangeId, this.prefs) : super(null) {
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    final jsonString = prefs.getString(prefsKey + exchangeId);
    if (jsonString != null) {
      final txn = Transaction.fromJson(jsonDecode(jsonString));
      state = txn;
    } else {
      state = null;
    }
  }

  Future<Transaction> add(Transaction transaction) async {
    if (state == null || state!.status != transaction.status) {
      state = transaction;
      final jsonString = jsonEncode(transaction.toJson());
      await prefs.setString(prefsKey + exchangeId, jsonString);
    }
    return transaction;
  }
}

@immutable
class TransactionProviderParameters {
  final Pfi pfi;
  final String exchangeId;

  const TransactionProviderParameters(this.pfi, this.exchangeId);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionProviderParameters &&
        other.pfi == pfi &&
        other.exchangeId == exchangeId;
  }

  @override
  int get hashCode => pfi.hashCode ^ exchangeId.hashCode;
}
