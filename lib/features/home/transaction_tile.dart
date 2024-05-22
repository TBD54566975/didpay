import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/features/home/transaction_details_page.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/tbdex/transaction_notifier.dart';
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
    final parameters = TransactionProviderParameters(pfi, exchangeId);
    final transactionState = ref.watch(transactionAsyncProvider(parameters));

    final transaction = useState<Transaction?>(null);
    final lastStatus = useState<TransactionStatus?>(null);

    ExchangeAsyncNotifier getTransactionsNotifier() =>
        ref.read(transactionAsyncProvider(parameters).notifier);

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

    useEffect(
      () {
        Future.delayed(Duration.zero, () {
          if (transaction.value != null &&
              (lastStatus.value == null ||
                  lastStatus.value != transaction.value?.status)) {
            lastStatus.value = transaction.value?.status;
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  transaction.value?.status.toString() ?? '',
                ),
                duration: const Duration(seconds: 1),
                backgroundColor: Theme.of(context).colorScheme.tertiary,
              ),
            );
          }
        });
        return null;
      },
      [transaction.value],
    );

    return transactionState.when(
      data: (txn) {
        if (txn == null) {
          return _buildErrorTile(context, Loc.of(context).noTransactionsFound);
        }
        transaction.value = txn;

        return ListTile(
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
                return TransactionDetailsPage(txn: txn);
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
