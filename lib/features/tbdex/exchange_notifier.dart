import 'dart:async';

import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

final exchangeProvider = AsyncNotifierProvider.family
    .autoDispose<ExchangeAsyncNotifier, Exchange?, ExchangeProviderParameters>(
  ExchangeAsyncNotifier.new,
);

class ExchangeAsyncNotifier extends AutoDisposeFamilyAsyncNotifier<Exchange?,
    ExchangeProviderParameters> {
  late String? _exchangeId;
  late Pfi? _pfi;
  Timer? _timer;

  @override
  FutureOr<Exchange?> build(ExchangeProviderParameters arg) async {
    _exchangeId = arg.exchangeId;
    _pfi = arg.pfi;
    return fetchExchange();
  }

  Future<Exchange?> fetchExchange() async {
    if (_pfi == null || _exchangeId == null) return null;

    try {
      final bearerDid = ref.read(didProvider);
      final tbdexService = ref.read(tbdexServiceProvider);
      final exchange =
          await tbdexService.getExchange(bearerDid, _pfi!, _exchangeId!);

      state = AsyncValue.data(exchange);
      return exchange;
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
      const Duration(seconds: 7),
      (timer) => fetchExchange(),
    );
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }
}

@immutable
class ExchangeProviderParameters {
  final Pfi pfi;
  final String exchangeId;

  const ExchangeProviderParameters(this.pfi, this.exchangeId);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExchangeProviderParameters &&
        other.pfi == pfi &&
        other.exchangeId == exchangeId;
  }

  @override
  int get hashCode => pfi.hashCode ^ exchangeId.hashCode;
}
