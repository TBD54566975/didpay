import 'dart:async';
import 'dart:math';

import 'package:didpay/config/config.dart';
import 'package:didpay/features/account/account_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

class QuoteAsyncNotifier extends AutoDisposeAsyncNotifier<Quote?> {
  static const _maxCallsPerInterval = 10;
  static const _maxPollingDuration = Duration(minutes: 2);

  static final List<Duration> _backoffIntervals = [
    const Duration(seconds: 1),
    const Duration(seconds: 5),
    const Duration(seconds: 10),
    const Duration(seconds: 20),
  ];

  int _numCalls = 0;
  Timer? _timer;
  DateTime? _pollingStart;
  Duration _currentInterval = _backoffIntervals.first;

  @override
  FutureOr<Quote?> build() => null;

  void startPolling(String exchangeId) {
    _timer?.cancel();
    _pollingStart ??= DateTime.now();

    if (DateTime.now().difference(_pollingStart!) > _maxPollingDuration) {
      state = AsyncValue.error(
        Exception('forced timeout after 2 minutes'),
        StackTrace.current,
      );
      stopPolling();
      return;
    }
    state = const AsyncValue.loading();

    _timer = Timer.periodic(_currentInterval, (_) async {
      try {
        final exchange = await _fetchExchange(exchangeId);
        if (_containsQuote(exchange)) {
          state = AsyncValue.data(_getQuote(exchange));
          stopPolling();
        } else {
          _increaseBackoff(exchangeId);
        }
      } on Exception catch (e) {
        state = AsyncValue.error(
          Exception('Failed to fetch exchange: $e'),
          StackTrace.current,
        );
        stopPolling();
      }
    });
  }

  void _increaseBackoff(String exchangeId) {
    _currentInterval = _backoffIntervals[
        min(_numCalls ~/ _maxCallsPerInterval, _backoffIntervals.length - 1)];
    _numCalls++;

    startPolling(exchangeId);
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
    _pollingStart = null;
    _numCalls = 0;
    _currentInterval = _backoffIntervals.first;
  }

  Future<Exchange> _fetchExchange(String exchangeId) async {
    final did = ref.read(didProvider);
    final country = ref.read(countryProvider);
    final pfi = Config.getPfi(country);

    final resp = await TbdexHttpClient.getExchange(
      did,
      pfi?.didUri ?? '',
      exchangeId,
    );

    return resp.data!;
  }

  bool _containsQuote(Exchange exchange) =>
      exchange.any((message) => message.metadata.kind == MessageKind.quote);

  Quote? _getQuote(Exchange exchange) => exchange.firstWhere(
        (message) => message.metadata.kind == MessageKind.quote,
      ) as Quote;
}
