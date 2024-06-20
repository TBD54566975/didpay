import 'dart:async';

import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final transactionProvider = AsyncNotifierProvider.family.autoDispose<
    TransactionNotifier, Transaction?, TransactionProviderParameters>(
  TransactionNotifier.new,
);

class TransactionNotifier extends AutoDisposeFamilyAsyncNotifier<Transaction?,
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

      if (Transaction.isClosed(transaction.status)) stopPolling();

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

@immutable
class TransactionProviderParameters extends Equatable {
  final Pfi pfi;
  final String exchangeId;

  const TransactionProviderParameters(this.pfi, this.exchangeId);

  @override
  List<Object?> get props => [pfi, exchangeId];
}
