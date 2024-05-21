import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/features/home/transaction_details_page.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/tbdex/exchange_notifier.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/utils/currency_util.dart';
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
    final parameters = ExchangeProviderParameters(pfi, exchangeId);
    final exchangeState = ref.watch(exchangeProvider(parameters));

    ExchangeAsyncNotifier getTransactionsNotifier() =>
        ref.read(exchangeProvider(parameters).notifier);

    useEffect(
      () {
        Future.delayed(
          Duration.zero,
          () => getTransactionsNotifier().startPolling(),
        );
        return getTransactionsNotifier().stopPolling;
      },
      [],
    );

    return exchangeState.when(
      data: (exchange) {
        if (exchange == null) {
          return _buildErrorTile(context, Loc.of(context).noTransactionsFound);
        }

        final transaction = Transaction.fromExchange(exchange);

        if (transaction.status == TransactionStatus.paymentCanceled) {
          getTransactionsNotifier().stopPolling();
        }

        return ListTile(
          title: Text(
            '${transaction.payinCurrency} → ${transaction.payoutCurrency}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          subtitle: Text(
            transaction.status.toString(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w300,
                ),
          ),
          trailing: _buildTransactionAmount(context, transaction),
          leading: Container(
            width: Grid.md,
            height: Grid.md,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(Grid.xxs),
            ),
            child: Center(
              child: Transaction.getIcon(transaction.type),
            ),
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) {
                return TransactionDetailsPage(
                  txn: transaction,
                );
              },
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
    Transaction transaction,
  ) {
    final modifier = transaction.type == TransactionType.send ? '-' : '+';
    final color = transaction.type == TransactionType.send
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.tertiary;
    return Text(
      transaction.type == TransactionType.deposit
          ? '$modifier${CurrencyUtil.formatFromDouble(
              transaction.payoutAmount,
              currency: transaction.payoutCurrency.toUpperCase(),
            )} ${transaction.payoutCurrency}'
          : '$modifier${CurrencyUtil.formatFromDouble(
              transaction.payinAmount,
              currency: transaction.payinCurrency.toUpperCase(),
            )} ${transaction.payinCurrency}',
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
