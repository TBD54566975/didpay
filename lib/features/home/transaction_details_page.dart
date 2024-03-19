import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/currency/currency.dart';
import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/success_page.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class TransactionDetailsPage extends HookWidget {
  final Transaction txn;
  const TransactionDetailsPage({required this.txn, super.key});

  @override
  Widget build(BuildContext context) {
    final payoutAmount = Currency.formatFromDouble(
      txn.payoutAmount,
      currency: CurrencyCode.values.byName(txn.payoutCurrency.toLowerCase()),
    );
    final payinAmount = Currency.formatFromDouble(
      txn.payinAmount,
      currency: CurrencyCode.values.byName(txn.payinCurrency.toLowerCase()),
    );

    return Scaffold(
      appBar: AppBar(title: Text(Loc.of(context).transactionDetails)),
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
                    _buildAmount(context, payoutAmount, payinAmount),
                    _buildStatus(context),
                    if (txn.status != TransactionStatus.failed)
                      _buildDetails(context, payoutAmount, payinAmount),
                  ],
                ),
              ),
            ),
            txn.status == TransactionStatus.quoted
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
            child: txn.type == TransactionType.deposit
                ? const Icon(Icons.south_west)
                : const Icon(Icons.north_east),
          ),
        ),
        const SizedBox(height: Grid.xxs),
        Text(
          '${txn.type}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildAmount(
    BuildContext context,
    String payoutAmount,
    String payinAmount,
  ) {
    return Column(
      children: [
        const SizedBox(height: Grid.xxl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: AutoSizeText(
                txn.type == TransactionType.deposit
                    ? payoutAmount
                    : payinAmount,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 1,
              ),
            ),
            const SizedBox(width: Grid.xs),
            Text(
              txn.type == TransactionType.deposit
                  ? txn.payoutCurrency
                  : txn.payinCurrency,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const Text('Mar 1 at 10:00 am'),
      ],
    );
  }

  Widget _buildStatus(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: Grid.lg),
        Icon(
          _getStatusIcon(txn.status),
          size: Grid.xl,
          color: _getStatusColor(context, txn.status),
        ),
        const SizedBox(height: Grid.xxs),
        Text(
          '${txn.status}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.quoted:
        return Icons.pending;
      case TransactionStatus.failed:
        return Icons.error;
      case TransactionStatus.completed:
        return Icons.check_circle;
    }
  }

  Color _getStatusColor(BuildContext context, TransactionStatus status) {
    var colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case TransactionStatus.failed:
        return colorScheme.error;
      case TransactionStatus.quoted:
        return colorScheme.onSurface;
      case TransactionStatus.completed:
        return colorScheme.primary;
    }
  }

  Widget _buildDetails(
    BuildContext context,
    String payoutAmount,
    String payinAmount,
  ) {
    final balanceLabel = Loc.of(context).accountBalance;
    final paymentLabel = txn.status == TransactionStatus.quoted
        ? txn.type == TransactionType.deposit
            ? Loc.of(context).youPay
            : Loc.of(context).youReceive
        : txn.type == TransactionType.deposit
            ? Loc.of(context).youPaid
            : Loc.of(context).youReceived;

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
                  child: Text(
                    paymentLabel,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    txn.type == TransactionType.deposit
                        ? '$payinAmount ${txn.payinCurrency}'
                        : '$payoutAmount ${txn.payoutCurrency}',
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
                    txn.type == TransactionType.deposit
                        ? '+$payoutAmount ${txn.payoutCurrency}'
                        : '-$payinAmount ${txn.payinCurrency}',
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
