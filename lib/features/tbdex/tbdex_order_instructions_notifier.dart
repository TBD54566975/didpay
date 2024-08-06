import 'dart:async';

import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:retry/retry.dart';
import 'package:tbdex/tbdex.dart';

final orderInstructionsProvider = AsyncNotifierProvider.autoDispose<
    TbdexOrderInstructionsNotifier, OrderInstructions?>(
  TbdexOrderInstructionsNotifier.new,
);

class TbdexOrderInstructionsNotifier
    extends AutoDisposeAsyncNotifier<OrderInstructions?> {
  Completer<void>? _completer;

  @override
  FutureOr<OrderInstructions?> build() => null;

  Future<OrderInstructions?> pollForOrderInstructions(
    String pfiDid,
    String? exchangeId,
  ) async {
    if (_completer == null || exchangeId == null) return null;

    return retry(
      () async {
        if (_completer?.isCompleted ?? false) return null;

        final exchange = await ref
            .read(tbdexServiceProvider)
            .getExchange(ref.read(didProvider), pfiDid, exchangeId);
        return _getOrderInstructions(exchange);
      },
      maxAttempts: 15,
      maxDelay: const Duration(seconds: 10),
      retryIf: (e) => e is _OrderInstructionsNotFoundException,
    );
  }

  Future<OrderInstructions?>? startPolling(String pfiDid, String exchangeId) {
    _completer = Completer();
    return pollForOrderInstructions(pfiDid, exchangeId);
  }

  void stopPolling() {
    if (_completer != null && !_completer!.isCompleted) {
      _completer?.complete();
    }
  }

  OrderInstructions _getOrderInstructions(Exchange exchange) =>
      exchange.firstWhere(
        (message) => message.metadata.kind == MessageKind.orderinstructions,
        orElse: () => throw _OrderInstructionsNotFoundException(),
      ) as OrderInstructions;
}

class _OrderInstructionsNotFoundException implements Exception {
  @override
  String toString() => 'Exception: OrderInstructions not found';
}
