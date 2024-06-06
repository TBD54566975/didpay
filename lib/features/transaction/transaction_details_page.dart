import 'package:auto_size_text/auto_size_text.dart';
import 'package:decimal/decimal.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/features/transaction/transaction_notifier.dart';
import 'package:didpay/shared/currency_formatter.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class TransactionDetailsPage extends HookConsumerWidget {
  final Pfi pfi;
  final String exchangeId;

  const TransactionDetailsPage({
    required this.pfi,
    required this.exchangeId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parameters = TransactionProviderParameters(pfi, exchangeId);
    final transactionState = ref.watch(transactionProvider(parameters));

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: transactionState.when(
          data: (transaction) => transaction == null
              ? Container()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTransactionType(context, transaction),
                    Flexible(child: Container()),
                    _buildTransactionDetails(context, transaction),
                    Flexible(flex: 3, child: Container()),
                    _buildTransactionStatus(
                      context,
                      transaction.status,
                    ),
                  ],
                ),
          loading: Container.new,
          error: (error, stackTrace) => Center(
            child: Text(error.toString()),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionType(BuildContext context, Transaction txn) => Column(
        children: [
          const SizedBox(height: Grid.xs),
          ExcludeSemantics(
            child: Center(
              child: Transaction.getIcon(txn.type, size: Grid.lg),
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

  Widget _buildTransactionDetails(
    BuildContext context,
    Transaction transaction,
  ) {
    final payoutAmount = Decimal.parse(
      transaction.payoutAmount,
    ).formatCurrency(transaction.payoutCurrency);
    final payinAmount = Decimal.parse(
      transaction.payinAmount,
    ).formatCurrency(transaction.payinCurrency);

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
                transaction.type == TransactionType.deposit
                    ? payoutAmount
                    : payinAmount,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 1,
              ),
            ),
            const SizedBox(width: Grid.xs),
            Text(
              transaction.type == TransactionType.deposit
                  ? transaction.payoutCurrency
                  : transaction.payinCurrency,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: Grid.xxs),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: AutoSizeText(
                transaction.type == TransactionType.deposit
                    ? payinAmount
                    : payoutAmount,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                maxLines: 1,
              ),
            ),
            const SizedBox(width: Grid.xs),
            Text(
              transaction.type == TransactionType.deposit
                  ? transaction.payinCurrency
                  : transaction.payoutCurrency,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
        const SizedBox(height: Grid.xxs),
        Text(
          DateFormat("MMM dd 'at' hh:mm a")
              .format(transaction.createdAt.toLocal()),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ],
    );
  }

  Widget _buildTransactionStatus(
    BuildContext context,
    TransactionStatus status,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Grid.side),
        child: OutlinedButton(
          onPressed: () => {},
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: Theme.of(context).colorScheme.onSurface,
              width: Grid.quarter,
            ),
            splashFactory: NoSplash.splashFactory,
          ),
          child: Text(
            status.toString(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Transaction.getStatusColor(context, status),
                ),
          ),
        ),
      );
}
