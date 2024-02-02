import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:flutter_starter/shared/grid.dart';
import 'package:flutter_starter/shared/transaction.dart';

class TransactionDetailsPage extends HookWidget {
  final Transaction txn;
  const TransactionDetailsPage({required this.txn, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction details')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(context),
                    _buildAmount(context),
                    _buildStatus(context),
                    txn.status == 'Failed'
                        ? Container()
                        : _buildDetails(context),
                  ],
                ),
              ),
            ),
            txn.status == 'Quoted'
                ? _buildResponseButtons(context)
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Grid.side),
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(Loc.of(context).done),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Grid.md),
      child: Column(
        children: [
          Center(
            child: Container(
              width: Grid.xxl,
              height: Grid.xxl,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Center(
                // TODO: use $ or first letter of name based on txn type
                child: Text(
                  '\$',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: Grid.xxs,
            ),
            child: Text(
              txn.type,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAmount(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Grid.xxl),
      child: Column(
        children: [
          Text(
            '${txn.amount} USD',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          // TODO: replace with createdAt time
          const Text('Mar 1 at 10:00 am'),
        ],
      ),
    );
  }

  Widget _buildStatus(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Grid.xs),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: Grid.sm,
              bottom: Grid.xxs,
            ),
            child: Icon(_getStatusIcon(txn.status),
                size: 50, color: _getStatusColor(context, txn.status)),
          ),
          Text(
            txn.status,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Quoted':
        return Icons.pending;
      case 'Failed':
        return Icons.error;
      case 'Completed':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(BuildContext context, String status) {
    var colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case 'Quoted':
        return colorScheme.secondary;
      case 'Failed':
        return colorScheme.error;
      case 'Completed':
        return colorScheme.primary;
      default:
        return colorScheme.outlineVariant;
    }
  }

  Widget _buildDetails(BuildContext context) {
    final paymentLabel = txn.status == 'Quoted'
        ? Loc.of(context).youPay
        : txn.type == 'Deposit'
            ? Loc.of(context).youPaid
            : Loc.of(context).youReceived;

    final balanceLabel = txn.status == 'Quoted'
        ? Loc.of(context).txnTypeQuote(txn.type)
        : Loc.of(context).accountBalance;

    final amount = txn.status == 'Completed'
        ? '${txn.type == 'Deposit' ? '+' : '-'}${txn.amount}'
        : txn.amount.toString();

    return Padding(
      padding: const EdgeInsets.only(
          top: Grid.xxl, left: Grid.side, right: Grid.side),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Grid.xxs),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    paymentLabel,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${txn.amount} USD',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Grid.xxs),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    balanceLabel,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  child: Text(
                    '$amount USD',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: Grid.sm,
        right: Grid.sm,
        bottom: Grid.xxs,
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: () {},
              child: Text(Loc.of(context).reject),
            ),
          ),
          const SizedBox(width: Grid.sm),
          Expanded(
            child: FilledButton(
              onPressed: () {},
              child: Text(Loc.of(context).accept),
            ),
          ),
        ],
      ),
    );
  }
}
