import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/currency/currency.dart';
import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/features/home/transaction_details_page.dart';
import 'package:didpay/features/request/deposit_page.dart';
import 'package:didpay/features/request/withdraw_page.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txns = ref.watch(transactionsProvider);
    final accountBalance = Currency.formatFromDouble(0);

    return Scaffold(
      appBar: AppBar(title: Text(Loc.of(context).home)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAccountBalance(context, accountBalance),
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
        ),
      ),
    );
  }

  Widget _buildAccountBalance(BuildContext context, String accountBalance) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Grid.side),
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
                      '${CurrencyCode.usdc}',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                          builder: (context) => const DepositPage(),
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
                          builder: (context) => const WithdrawPage(),
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
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
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
                  builder: (context) => const DepositPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context, List<Transaction> txns) {
    return ListView(
      children: txns.map((txn) {
        final payoutAmount = Currency.formatFromDouble(
          txn.payoutAmount,
          currency:
              CurrencyCode.values.byName(txn.payoutCurrency.toLowerCase()),
        );
        final payinAmount = Currency.formatFromDouble(
          txn.payinAmount,
          currency: CurrencyCode.values.byName(txn.payinCurrency.toLowerCase()),
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
            '${txn.type == TransactionType.deposit ? payoutAmount : payinAmount} ${CurrencyCode.usdc}',
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
}
