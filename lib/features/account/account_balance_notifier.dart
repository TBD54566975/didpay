import 'dart:async';

import 'package:didpay/features/account/account_balance.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final accountBalanceProvider = AsyncNotifierProvider.family
    .autoDispose<AccountBalanceNotifier, AccountBalance?, List<Pfi>>(
  AccountBalanceNotifier.new,
);

class AccountBalanceNotifier
    extends AutoDisposeFamilyAsyncNotifier<AccountBalance?, List<Pfi>> {
  late List<Pfi>? _pfis;
  Timer? _timer;

  @override
  FutureOr<AccountBalance?> build(List<Pfi> arg) async {
    _pfis = arg;
    return fetchAccountBalance();
  }

  Future<AccountBalance?> fetchAccountBalance() async {
    if (_pfis == null || _pfis!.isEmpty) return null;

    try {
      final tbdexService = ref.read(tbdexServiceProvider);
      final accountBalance = await tbdexService.getAccountBalance(_pfis!);

      state = AsyncValue.data(accountBalance);
      return accountBalance;
    } on Exception catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
    return null;
  }

  void startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(minutes: 3),
      (timer) => fetchAccountBalance(),
    );
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }
}
