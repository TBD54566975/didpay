import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/utils/currency_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

class TransactionDetailsPage extends HookWidget {
  final Transaction txn;

  const TransactionDetailsPage({
    required this.txn,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final payoutAmount = CurrencyUtil.formatFromDouble(
      txn.payoutAmount,
      currency: txn.payoutCurrency.toUpperCase(),
    );
    final payinAmount = CurrencyUtil.formatFromDouble(
      txn.payinAmount,
      currency: txn.payinCurrency.toUpperCase(),
    );

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            Flexible(child: Container()),
            _buildAmounts(
              context,
              payoutAmount,
              payinAmount,
            ),
            Flexible(
              flex: 3,
              child: Container(),
            ),
            _buildStatusButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Column(
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

  Widget _buildAmounts(
    BuildContext context,
    String payoutAmount,
    String payinAmount,
  ) =>
      Column(
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
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
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
                  txn.type == TransactionType.deposit
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
                txn.type == TransactionType.deposit
                    ? txn.payinCurrency
                    : txn.payoutCurrency,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ],
          ),
          const SizedBox(height: Grid.xxs),
          Text(
            DateFormat("MMM dd 'at' hh:mm a").format(txn.createdAt.toLocal()),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ],
      );

  Widget _buildStatusButton(BuildContext context) => Padding(
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
            txn.status.toString(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
          ),
        ),
      );
}
