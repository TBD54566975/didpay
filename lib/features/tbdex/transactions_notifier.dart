import 'dart:async';

import 'package:didpay/features/tbdex/tbdex_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

// TODO(ethan-tbd): add polling to fetch transactions, https://github.com/TBD54566975/didpay/issues/136
class TransactionsAsyncNotifier
    extends AutoDisposeAsyncNotifier<List<Exchange>?> {
  @override
  FutureOr<List<Exchange>?> build() => null;

  Future<void> fetch() async {
    state = const AsyncValue.loading();

    try {
      final exchangeIds = await ref.read(exchangesProvider.future);
      final exchanges = <Exchange>[];
      for (final exchangeId in exchangeIds) {
        final exchange = await ref.read(exchangeProvider(exchangeId).future);
        exchanges.add(exchange);
      }
      state = AsyncValue.data(exchanges);
    } on Exception catch (e) {
      state = AsyncValue.error(
        e,
        StackTrace.current,
      );
    }
  }
}
