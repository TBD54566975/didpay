import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_starter/features/deposit/deposit_page.dart';
import 'package:flutter_starter/features/home/transaction_details_page.dart';
import 'package:flutter_starter/features/withdraw/withdraw_page.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:flutter_starter/shared/grid.dart';

class HomePage extends HookWidget {
  HomePage({super.key});

  // Will be replaced when we have real data
  final List<Transaction> txns = [
    Transaction(
      type: 'Deposit',
      status: 'Quoted',
      amount: 4.61,
    ),
    Transaction(
      type: 'Withdrawal',
      status: 'Quoted',
      amount: 20.85,
    ),
    Transaction(
      type: 'Deposit',
      status: 'Completed',
      amount: 10.99,
    ),
    Transaction(
      type: 'Withdrawal',
      status: 'Completed',
      amount: 7.03,
    ),
    Transaction(
      type: 'Withdrawal',
      status: 'Failed',
      amount: 5.42,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Loc.of(context).home)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAccountBalance(context),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Grid.side, vertical: Grid.xs),
              child: Text(
                Loc.of(context).activity,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Expanded(
              child: txns.isEmpty
                  ? _buildEmptyState(context)
                  : _buildTransactionsList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountBalance(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Grid.side),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.outline, width: 2.0),
          borderRadius: BorderRadius.circular(Grid.radius),
        ),
        padding: const EdgeInsets.all(Grid.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Loc.of(context).accountBalance,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: Grid.xxs),
            Center(
              child: Text(
                '\$0.00',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: Grid.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const DepositPage(),
                        ));
                      },
                      child: Text(Loc.of(context).deposit)),
                ),
                const SizedBox(width: Grid.xs),
                Expanded(
                  child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const WithdrawPage(),
                        ));
                      },
                      child: Text(Loc.of(context).withdraw)),
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
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const DepositPage(),
              ));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context) {
    return ListView(
      children: txns.map((txn) {
        return ListTile(
          // TODO: display name for payments and type for deposits/withdrawals
          title: Text(
            txn.type,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          // TODO: display status from txn
          subtitle: Text(
            txn.status,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w300,
                ),
          ),
          trailing: Text(txn.amount.toString()),
          leading: Container(
            width: Grid.lg,
            height: Grid.lg,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              shape: BoxShape.circle,
            ),
            // TODO: use $ or first letter of name based on txn type
            child: const Center(
              child: Text('\$'),
            ),
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) {
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

// Will be replaced with FTL-generated types later
class Transaction {
  final String type;
  final String status;
  final double amount;

  Transaction({
    required this.type,
    required this.status,
    required this.amount,
  });
}
