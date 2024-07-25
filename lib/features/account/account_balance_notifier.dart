import 'dart:async';

import 'package:didpay/features/account/account_balance.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web5/web5.dart';

final accountBalanceProvider =
    AsyncNotifierProvider.autoDispose<AccountBalanceNotifier, AccountBalance?>(
  AccountBalanceNotifier.new,
);

class AccountBalanceNotifier extends AutoDisposeAsyncNotifier<AccountBalance?> {
  Timer? _timer;

  @override
  FutureOr<AccountBalance?> build() async => null;

  Future<AccountBalance?> fetchAccountBalance(
    BearerDid did,
    List<Pfi>? pfis,
  ) async {
    if (pfis == null || pfis.isEmpty) return null;

    try {
      final tbdexService = ref.read(tbdexServiceProvider);
      final accountBalance = await tbdexService.getAccountBalance(did, pfis);

      state = AsyncValue.data(accountBalance);
      return accountBalance;
    } on Exception catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
    return null;
  }

  void startPolling(BearerDid did, List<Pfi> pfis) {
    _timer?.cancel();
    fetchAccountBalance(did, pfis);

    _timer = Timer.periodic(
      const Duration(minutes: 3),
      (timer) => fetchAccountBalance(did, pfis),
    );
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }
}
