import 'package:decimal/decimal.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/features/transaction/transaction_details_page.dart';
import 'package:didpay/features/transaction/transaction_notifier.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/currency_formatter.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/tile_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class TransactionTile extends HookConsumerWidget {
  final Pfi pfi;
  final String exchangeId;

  const TransactionTile({
    required this.pfi,
    required this.exchangeId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parameters = TransactionProviderParameters(pfi, exchangeId);
    final transaction = ref.watch(transactionProvider(parameters));

    TransactionNotifier getTransactionsNotifier() =>
        ref.read(transactionProvider(parameters).notifier);

    useEffect(
      () {
        Future.microtask(() async => getTransactionsNotifier().startPolling());
        return getTransactionsNotifier().stopPolling;
      },
      [],
    );

    return transaction.when(
      data: (txn) {
        if (txn == null) {
          return _buildErrorTile(context, Loc.of(context).noTransactionsFound);
        }

        return TileContainer(
          child: ListTile(
            title: Text(
              '${txn.payinCurrency} → ${txn.payoutCurrency}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            subtitle: Text(
              txn.status.toString(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                  ),
            ),
            trailing: _buildTransactionAmount(context, txn),
            leading: Container(
              width: Grid.md,
              height: Grid.md,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(Grid.xxs),
              ),
              child: Center(
                child: Transaction.getIcon(txn.type),
              ),
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) {
                  return TransactionDetailsPage(
                    pfi: pfi,
                    exchangeId: exchangeId,
                  );
                },
              ),
            ),
          ),
        );
      },
      loading: Container.new,
      error: (error, stackTrace) => _buildErrorTile(context, error.toString()),
    );
  }

  Widget _buildTransactionAmount(
    BuildContext context,
    Transaction txn,
  ) {
    final modifier = txn.type == TransactionType.send ? '-' : '+';
    final color = txn.type == TransactionType.send
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.tertiary;
    return Text(
      txn.type == TransactionType.deposit
          ? '$modifier${Decimal.parse(
              txn.payoutAmount,
            ).formatCurrency(txn.payoutCurrency)} ${txn.payoutCurrency}'
          : '$modifier${Decimal.parse(
              txn.payinAmount,
            ).formatCurrency(txn.payinCurrency)} ${txn.payinCurrency}',
      style: TextStyle(
        color: color,
      ),
    );
  }

  Widget _buildErrorTile(BuildContext context, String error) => ListTile(
        title: Text(
          error,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        leading: Container(
          width: Grid.md,
          height: Grid.md,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(Grid.xxs),
          ),
          child: Center(
            child:
                Icon(Icons.error, color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
}
