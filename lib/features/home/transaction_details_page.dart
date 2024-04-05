import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/currency/currency.dart';
import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class TransactionDetailsPage extends HookWidget {
  final Transaction txn;

  const TransactionDetailsPage({
    required this.txn,
    super.key,
  });

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
              child: txn.type == TransactionType.deposit
                  ? const Icon(Icons.south_west, size: Grid.lg)
                  : const Icon(Icons.north_east, size: Grid.lg),
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
            'Mar 1 at 10:00 am',
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
          child: _getStatusText(context, txn.status),
        ),
      );

  Text _getStatusText(BuildContext context, TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return Text(
          Loc.of(context).pending,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        );
      case TransactionStatus.failed:
        return Text(
          Loc.of(context).failed,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
        );
      case TransactionStatus.completed:
        return Text(
          Loc.of(context).completed,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.tertiary,
              ),
        );
    }
  }
}
