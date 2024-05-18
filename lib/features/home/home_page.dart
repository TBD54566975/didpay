import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/features/home/transaction_details_page.dart';
import 'package:didpay/features/payin/deposit_page.dart';
import 'package:didpay/features/payout/withdraw_page.dart';
import 'package:didpay/features/pfis/add_pfi_page.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/tbdex/rfq_state.dart';
import 'package:didpay/features/tbdex/transactions_notifier.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/utils/currency_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txns = ref.watch(transactionsProvider);
    final pfis = ref.watch(pfisProvider);

    // TODO(ethan-tbd): get balance from pfi, https://github.com/TBD54566975/didpay/issues/109
    final accountBalance = CurrencyUtil.formatFromDouble(0);

    TransactionsAsyncNotifier getTransactionsNotifier() =>
        ref.read(transactionsProvider.notifier);

    useEffect(
      () {
        Future.delayed(
          Duration.zero,
          () => getTransactionsNotifier().fetch(pfis),
        );
        return null;
      },
      [],
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAccountBalance(context, accountBalance, pfis),
            Expanded(
              child: pfis.isEmpty
                  ? _buildGetStarted(
                      context,
                      Loc.of(context).noPfisFound,
                      Loc.of(context).startByAddingAPfi,
                      false,
                    )
                  : _buildActivity(
                      context,
                      getTransactionsNotifier(),
                      pfis,
                      txns,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountBalance(
    BuildContext context,
    String accountBalance,
    List<Pfi> pfis,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(
          vertical: Grid.xs,
          horizontal: Grid.side,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(Grid.radius),
          ),
          padding: const EdgeInsets.all(Grid.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Loc.of(context).accountBalance,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: Grid.xxs),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: AutoSizeText(
                        accountBalance,
                        style:
                            Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: Grid.half),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Grid.xxs),
                      child: Text(
                        'USDC',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Grid.xs),
              if (pfis.isNotEmpty) _buildDepositWithdrawButtons(context, pfis),
            ],
          ),
        ),
      );

  Widget _buildDepositWithdrawButtons(
    BuildContext context,
    List<Pfi> pfis,
  ) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const DepositPage(rfqState: RfqState()),
                  ),
                );
              },
              child: Text(Loc.of(context).deposit),
            ),
          ),
          const SizedBox(width: Grid.xs),
          Expanded(
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const WithdrawPage(rfqState: RfqState()),
                  ),
                );
              },
              child: Text(Loc.of(context).withdraw),
            ),
          ),
        ],
      );

  Widget _buildActivity(
    BuildContext context,
    TransactionsAsyncNotifier notifier,
    List<Pfi> pfis,
    AsyncValue<List<Exchange>?> exchangesStatus,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Grid.side,
              vertical: Grid.xs,
            ),
            child: Text(
              Loc.of(context).activity,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: exchangesStatus.when(
              data: (exchange) => exchange == null || exchange.isEmpty
                  ? _buildGetStarted(
                      context,
                      Loc.of(context).noTransactionsYet,
                      Loc.of(context).startByAdding,
                      true,
                    )
                  : RefreshIndicator(
                      onRefresh: () async => notifier.fetch(pfis),
                      child: _buildTransactionsList(context, exchange),
                    ),
              error: (error, stackTrace) => _buildTransactionsError(
                context,
                notifier,
                pfis,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      );

  Widget _buildTransactionsList(
    BuildContext context,
    List<Exchange> exchanges,
  ) =>
      ListView(
        reverse: true,
        children: exchanges.map((exchange) {
          final transaction = Transaction.fromExchange(exchange);

          return ListTile(
            title: Text(
              '${transaction.type}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            subtitle: _getTxnSubtitle(context, transaction),
            trailing: _getTxnTrailing(transaction),
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
        }).toList(),
      );

  // TODO(ethan-tbd): update empty state, https://github.com/TBD54566975/didpay/issues/125
  Widget _buildGetStarted(
    BuildContext context,
    String title,
    String? subtitle,
    bool hasPfis,
  ) =>
      Center(
        child: Column(
          children: [
            const SizedBox(height: Grid.xs),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: Grid.xxs),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: Grid.xxs),
            FilledButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.secondaryContainer,
                ),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => hasPfis
                      ? const DepositPage(rfqState: RfqState())
                      : AddPfiPage(),
                ),
              ),
              child: Text(Loc.of(context).getStarted),
            ),
          ],
        ),
      );

  // TODO(ethan-tbd): update error state, https://github.com/TBD54566975/didpay/issues/125
  Widget _buildTransactionsError(
    BuildContext context,
    TransactionsAsyncNotifier notifier,
    List<Pfi> pfis,
  ) =>
      Center(
        child: Column(
          children: [
            const SizedBox(height: Grid.xs),
            Text(
              Loc.of(context).unableToRetrieveTxns,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: Grid.xxs),
            FilledButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.secondaryContainer,
                ),
              ),
              onPressed: () async => notifier.fetch(pfis),
              child: Text(Loc.of(context).tapToRetry),
            ),
          ],
        ),
      );

  Widget _getTxnSubtitle(BuildContext context, Transaction transaction) => Text(
        transaction.type == TransactionType.deposit
            ? '${transaction.payinCurrency} → account balance'
            : 'Account balance → ${transaction.payoutCurrency}',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w300,
            ),
      );

  Widget _getTxnTrailing(Transaction transaction) => Text(
        transaction.type == TransactionType.deposit
            ? '${CurrencyUtil.formatFromDouble(
                transaction.payoutAmount,
                currency: transaction.payoutCurrency.toUpperCase(),
              )} ${transaction.payoutCurrency}'
            : '${CurrencyUtil.formatFromDouble(
                transaction.payinAmount,
                currency: transaction.payinCurrency.toUpperCase(),
              )} ${transaction.payinCurrency}',
      );
}
