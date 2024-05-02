import 'dart:async';

import 'package:didpay/config/config.dart';
import 'package:didpay/features/account/account_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

class QuoteAsyncNotifier extends AsyncNotifier<Quote?> {
  static const _refreshInterval = Duration(seconds: 2);
  Timer? _timer;

  @override
  FutureOr<Quote?> build() {
    return null;
  }

  void startPolling(String exchangeId) {
    _timer?.cancel();
    _timer = Timer.periodic(_refreshInterval, (_) async {
      try {
        final exchange = await _fetchExchange(exchangeId);
        if (_containsQuote(exchange)) {
          state = AsyncValue.data(_getQuote(exchange));
          _stopPolling();
        } else {
          state = const AsyncValue.loading();
        }
      } on Exception catch (e) {
        state = AsyncValue.error(e, StackTrace.current);
        _stopPolling();
      }
    });
  }

  void _stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  Future<Exchange> _fetchExchange(String exchangeId) async {
    final did = ref.read(didProvider);
    final country = ref.read(countryProvider);
    final pfi = Config.getPfi(country);

    final exchange = await TbdexHttpClient.getExchange(
      did,
      pfi?.didUri ?? '',
      exchangeId,
    );

    return exchange;
  }

  bool _containsQuote(Exchange exchange) =>
      exchange.any((message) => message.metadata.kind == MessageKind.quote);

  Quote? _getQuote(Exchange exchange) => exchange.firstWhere(
        (message) => message.metadata.kind == MessageKind.quote,
      ) as Quote;
}
