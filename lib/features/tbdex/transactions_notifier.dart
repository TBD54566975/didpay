import 'dart:async';

import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

final transactionsProvider = AsyncNotifierProvider.autoDispose<
    TransactionsAsyncNotifier, List<Exchange>?>(
  TransactionsAsyncNotifier.new,
);

// TODO(ethan-tbd): add polling to fetch transactions, https://github.com/TBD54566975/didpay/issues/136
class TransactionsAsyncNotifier
    extends AutoDisposeAsyncNotifier<List<Exchange>?> {
  @override
  FutureOr<List<Exchange>?> build() => null;

  Future<void> fetch(List<Pfi> pfis) async {
    state = const AsyncValue.loading();

    try {
      final bearerDid = ref.read(didProvider);
      final tbdexService = ref.read(tbdexServiceProvider);
      final exchangesMap = await tbdexService.getExchanges(bearerDid, pfis);

      final exchanges = await Future.wait(
        exchangesMap.entries
            .expand(
              (entry) => entry.value.map(
                (exchangeId) =>
                    tbdexService.getExchange(bearerDid, entry.key, exchangeId),
              ),
            )
            .toList(),
      );
      state = AsyncValue.data(exchanges);
    } on Exception catch (e) {
      state = AsyncValue.error(
        e,
        StackTrace.current,
      );
    }
  }
}
