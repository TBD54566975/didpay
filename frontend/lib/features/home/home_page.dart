import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_starter/features/deposit/deposit_page.dart';
import 'package:flutter_starter/features/home/account_balance.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:flutter_starter/shared/grid.dart';

class HomePage extends HookWidget {
  HomePage({super.key});

  final List<Transaction> txns = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Loc.of(context).home)),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AccountBalance(),
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
                  ? buildEmptyState(context)
                  : ListView(
                      children: txns.map((txn) {
                        return ListTile(
                          title: Text(
                            txn.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          // TODO: display status from txn
                          subtitle: Text(
                            'status',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w300,
                                ),
                          ),
                          trailing: Text(txn.amount.toString()),
                          leading: Container(
                            width: Grid.lg,
                            height: Grid.lg,
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).colorScheme.surfaceVariant,
                              shape: BoxShape.circle,
                            ),
                            // TODO: use $ or first letter of name based on txn type
                            child: const Center(
                              child: Text('\$'),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
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
}

// Will be replaced with FTL-generated types later
class Transaction {
  final String title;
  final double amount;

  Transaction({required this.title, required this.amount});
}
