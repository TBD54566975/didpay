import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/account/account_balance_notifier.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AccountBalanceDisplay extends HookConsumerWidget {
  const AccountBalanceDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pfis = ref.watch(pfisProvider);
    final accountBalance = ref.watch(accountBalanceProvider(pfis));

    final accountTotal = accountBalance.asData?.value?.total ?? '';
    final accountCurrency = accountBalance.asData?.value?.currencyCode ?? '';

    AccountBalanceNotifier getAccountBalanceNotifier() =>
        ref.read(accountBalanceProvider(pfis).notifier);

    useEffect(
      () {
        Future.microtask(
          () async => getAccountBalanceNotifier().startPolling(),
        );
        return getAccountBalanceNotifier().stopPolling;
      },
      [],
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Flexible(
          child: AutoSizeText(
            accountTotal,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 1,
          ),
        ),
        const SizedBox(width: Grid.half),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Grid.xxs),
          child: Text(
            accountCurrency,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
}
