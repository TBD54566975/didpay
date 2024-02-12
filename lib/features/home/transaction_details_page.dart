import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/success_page.dart';
import 'package:didpay/features/home/transaction.dart';

class TransactionDetailsPage extends HookWidget {
  final Transaction txn;
  const TransactionDetailsPage({required this.txn, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Loc.of(context).transactionDetails),
        scrolledUnderElevation: 0,
      ),
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
                    if (txn.status != Status.failed) _buildDetails(context)
                  ],
                ),
              ),
            ),
            txn.status == Status.quoted
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
    return Column(
      children: [
        const SizedBox(height: Grid.md),
        ExcludeSemantics(
          child: Center(
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
        ),
        const SizedBox(height: Grid.xxs),
        Text(
          txn.type,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildAmount(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Grid.xxl),
        Text(
          '${txn.amount} USD',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        // TODO: replace with createdAt time
        const Text('Mar 1 at 10:00 am'),
      ],
    );
  }

  Widget _buildStatus(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Grid.lg),
        Icon(_getStatusIcon(txn.status),
            size: Grid.xl, color: _getStatusColor(context, txn.status)),
        const SizedBox(height: Grid.xxs),
        Text(
          txn.status,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case Status.quoted:
        return Icons.pending;
      case Status.failed:
        return Icons.error;
      case Status.completed:
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(BuildContext context, String status) {
    var colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case Status.quoted:
        return colorScheme.secondary;
      case Status.failed:
        return colorScheme.error;
      case Status.completed:
        return colorScheme.primary;
      default:
        return colorScheme.outlineVariant;
    }
  }

  Widget _buildDetails(BuildContext context) {
    final paymentLabel = txn.status == Status.quoted
        ? Loc.of(context).youPay
        : txn.type == Type.deposit
            ? Loc.of(context).youPaid
            : Loc.of(context).youReceived;

    final balanceLabel = txn.status == Status.quoted
        ? Loc.of(context).txnTypeQuote(txn.type)
        : Loc.of(context).accountBalance;

    final amount = txn.status == Status.completed
        ? '${txn.type == Type.deposit ? '+' : '-'}${txn.amount}'
        : txn.amount.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Grid.side),
      child: Column(
        children: [
          const SizedBox(height: Grid.xxl),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Grid.xxs),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    paymentLabel,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${txn.amount} USD',
                    style: Theme.of(context).textTheme.bodyLarge,
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
                  flex: 2,
                  child: Text(
                    balanceLabel,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '$amount USD',
                    style: Theme.of(context).textTheme.bodyLarge,
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
      padding: const EdgeInsets.symmetric(horizontal: Grid.sm),
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
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SuccessPage(
                      text: Loc.of(context).yourRequestWasSent,
                    ),
                  ),
                );
              },
              child: Text(Loc.of(context).accept),
            ),
          ),
        ],
      ),
    );
  }
}
