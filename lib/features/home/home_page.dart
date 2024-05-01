import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/features/home/transaction_details_page.dart';
import 'package:didpay/features/payin/deposit_page.dart';
import 'package:didpay/features/payout/withdraw_page.dart';
import 'package:didpay/features/tbdex/rfq_state.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/utils/currency_util.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txns = ref.watch(transactionsProvider);
    // TODO(ethan-tbd): get balance from pfi, https://github.com/TBD54566975/didpay/issues/109
    final accountBalance = CurrencyUtil.formatFromDouble(0);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAccountBalance(context, accountBalance),
            Expanded(
              child: _buildActivityList(context, txns),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountBalance(BuildContext context, String accountBalance) =>
      Padding(
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
              Text(
                Loc.of(context).accountBalance,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: Grid.xxs),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: AutoSizeText(
                        accountBalance,
                        style:
                            Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: Grid.half),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Grid.xxs),
                      child: Text(
                        'USDC',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Grid.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const DepositPage(rfqState: RfqState()),
                          ),
                        );
                      },
                      child: Text(Loc.of(context).deposit),
                    ),
                  ),
                  const SizedBox(width: Grid.xs),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const WithdrawPage(rfqState: RfqState()),
                          ),
                        );
                      },
                      child: Text(Loc.of(context).withdraw),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildActivityList(BuildContext context, List<Transaction> txns) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Grid.side,
              vertical: Grid.xs,
            ),
            child: Text(
              Loc.of(context).activity,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: txns.isEmpty
                ? _buildEmptyState(context)
                : _buildTransactionsList(context, txns),
          ),
        ],
      );

  Widget _buildEmptyState(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: Grid.xxs),
            Text(
              Loc.of(context).noTransactionsYet,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(Loc.of(context).startByAdding),
            const SizedBox(height: Grid.xxs),
            FilledButton(
              child: Text(Loc.of(context).getStarted),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const DepositPage(rfqState: RfqState()),
                  ),
                );
              },
            ),
          ],
        ),
      );

  Widget _buildTransactionsList(BuildContext context, List<Transaction> txns) =>
      ListView(
        children: txns.map((txn) {
          final payoutAmount = CurrencyUtil.formatFromDouble(
            txn.payoutAmount,
            currency: txn.payoutCurrency.toUpperCase(),
          );
          final payinAmount = CurrencyUtil.formatFromDouble(
            txn.payinAmount,
            currency: txn.payinCurrency.toUpperCase(),
          );

          return ListTile(
            title: Text(
              '${txn.type}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            subtitle: Text(
              '${txn.status}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                  ),
            ),
            trailing: Text(
              '${txn.type == TransactionType.deposit ? payoutAmount : payinAmount} USDC',
            ),
            leading: Container(
              width: Grid.md,
              height: Grid.md,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(Grid.xxs),
              ),
              child: Center(
                child: txn.type == TransactionType.deposit
                    ? const Icon(Icons.south_west)
                    : const Icon(Icons.north_east),
              ),
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) {
                  return TransactionDetailsPage(
                    txn: txn,
                  );
                },
              ),
            ),
          );
        }).toList(),
      );
}
