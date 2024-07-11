import 'dart:async';

import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:retry/retry.dart';
import 'package:tbdex/tbdex.dart';

final quoteProvider =
    AsyncNotifierProvider.autoDispose<TbdexQuoteNotifier, Quote?>(
  TbdexQuoteNotifier.new,
);

class TbdexQuoteNotifier extends AutoDisposeAsyncNotifier<Quote?> {
  Completer<void>? _completer;

  @override
  FutureOr<Quote?> build() => null;

  Future<Quote?> pollForQuote(String pfiDid, String? exchangeId) async {
    if (_completer == null || exchangeId == null) return null;

    return retry(
      () async {
        if (_completer?.isCompleted ?? false) return null;

        final exchange = await ref
            .read(tbdexServiceProvider)
            .getExchange(ref.read(didProvider), pfiDid, exchangeId);
        return _getQuote(exchange);
      },
      maxAttempts: 15,
      maxDelay: const Duration(seconds: 10),
      retryIf: (e) => e is _QuoteNotFoundException,
    );
  }

  Future<Quote?>? startPolling(String pfiDid, String exchangeId) {
    _completer = Completer();
    return pollForQuote(pfiDid, exchangeId);
  }

  void stopPolling() {
    if (_completer != null && !_completer!.isCompleted) {
      _completer?.complete();
    }
  }

  Quote _getQuote(Exchange exchange) => exchange.firstWhere(
        (message) => message.metadata.kind == MessageKind.quote,
        orElse: () => throw _QuoteNotFoundException(),
      ) as Quote;
}

class _QuoteNotFoundException implements Exception {
  @override
  String toString() => 'Exception: Quote not found';
}
