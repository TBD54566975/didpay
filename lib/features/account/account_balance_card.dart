import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/account/account_balance_notifier.dart';
import 'package:didpay/features/payment/payment_amount_page.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AccountBalanceCard extends HookConsumerWidget {
  const AccountBalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pfis = ref.watch(pfisProvider);
    final accountBalance = ref.watch(accountBalanceProvider);

    final accountTotal = accountBalance.asData?.value?.total ?? '0';
    final accountCurrency = accountBalance.asData?.value?.currencyCode ?? '';

    AccountBalanceNotifier getAccountBalanceNotifier() =>
        ref.read(accountBalanceProvider.notifier);

    useEffect(
      () {
        Future.microtask(
          () async => getAccountBalanceNotifier().startPolling(pfis),
        );
        return getAccountBalanceNotifier().stopPolling;
      },
      [],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: Grid.xs,
        horizontal: Grid.side,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(Grid.radius),
        ),
        padding: const EdgeInsets.all(Grid.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardTitle(context),
            const SizedBox(height: Grid.xxs),
            _buildAccountBalance(context, accountTotal, accountCurrency),
            const SizedBox(height: Grid.xs),
            if (pfis.isNotEmpty) _buildDepositWithdrawButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCardTitle(BuildContext context) => AutoSizeText(
        Loc.of(context).accountBalance,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
        textScaleFactor: 1.1,
        maxLines: 1,
      );

  Widget _buildAccountBalance(
    BuildContext context,
    String accountTotal,
    String accountCurrency,
  ) {
    final accountTotalText = AutoSizeText(
      accountTotal,
      style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
      maxLines: 1,
    );
    final accountCurrencyText = AutoSizeText(
      accountCurrency,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
      maxFontSize: accountTotalText.maxFontSize - 20,
      maxLines: 1,
    );

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Flexible(child: accountTotalText),
          const SizedBox(width: Grid.xxs),
          Flexible(child: accountCurrencyText),
        ],
      ),
    );
  }

  Widget _buildDepositWithdrawButtons(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PaymentAmountPage(
                    paymentState: PaymentState(
                      transactionType: TransactionType.deposit,
                    ),
                  ),
                  fullscreenDialog: true,
                ),
              ),
              child: Flexible(
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Grid.xs),
                    child: AutoSizeText(
                      Loc.of(context).deposit,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: Grid.xs),
          Expanded(
            child: FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PaymentAmountPage(
                    paymentState: PaymentState(
                      transactionType: TransactionType.withdraw,
                    ),
                  ),
                  fullscreenDialog: true,
                ),
              ),
              child: Flexible(
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Grid.xs),
                    child: AutoSizeText(
                      Loc.of(context).withdraw,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
}
