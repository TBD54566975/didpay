import 'package:auto_size_text/auto_size_text.dart';
import 'package:decimal/decimal.dart';
import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/payment/payment_amount_page.dart';
import 'package:didpay/features/pfis/add_pfi_page.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/features/transaction/transaction_tile.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pfis = ref.read(pfisProvider);

    final getExchangesState =
        useState<AsyncValue<Map<Pfi, List<String>>>>(const AsyncLoading());

    // TODO(ethan-tbd): get balance from pfi, https://github.com/TBD54566975/didpay/issues/109
    final accountBalance = Decimal.parse('0');

    useEffect(
      () {
        _getExchanges(ref, getExchangesState);
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
                      ref,
                      Loc.of(context).noPfisFound,
                      Loc.of(context).startByAddingAPfi,
                    )
                  : _buildTransactionsActivity(
                      context,
                      ref,
                      getExchangesState,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountBalance(
    BuildContext context,
    Decimal accountBalance,
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
                        accountBalance.toString(),
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
                    builder: (context) => const PaymentAmountPage(
                      transactionType: TransactionType.deposit,
                    ),
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
                    builder: (context) => const PaymentAmountPage(
                      transactionType: TransactionType.withdraw,
                    ),
                  ),
                );
              },
              child: Text(Loc.of(context).withdraw),
            ),
          ),
        ],
      );

  Widget _buildTransactionsActivity(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<AsyncValue<Map<Pfi, List<String>>>> pfiToExchangeIdsState,
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
            child: pfiToExchangeIdsState.value.when(
              data: (exchangeMap) => exchangeMap.isEmpty
                  ? _buildGetStarted(
                      context,
                      ref,
                      Loc.of(context).noTransactionsYet,
                      Loc.of(context).startByAdding,
                    )
                  : RefreshIndicator(
                      onRefresh: () async =>
                          _getExchanges(ref, pfiToExchangeIdsState),
                      child: ListView(
                        children: exchangeMap.entries
                            .expand(
                              (pfiToExchangeIds) =>
                                  pfiToExchangeIds.value.reversed.map(
                                (exchangeId) => TransactionTile(
                                  pfi: pfiToExchangeIds.key,
                                  exchangeId: exchangeId,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
              error: (error, stackTrace) => _buildTransactionsError(
                context,
                ref,
                pfiToExchangeIdsState,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      );

  // TODO(ethan-tbd): update empty state, https://github.com/TBD54566975/didpay/issues/125
  Widget _buildGetStarted(
    BuildContext context,
    WidgetRef ref,
    String title,
    String? subtitle,
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
                  builder: (context) => ref.read(pfisProvider).isEmpty
                      ? AddPfiPage()
                      : const PaymentAmountPage(
                          transactionType: TransactionType.deposit,
                        ),
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
    WidgetRef ref,
    ValueNotifier<AsyncValue<Map<Pfi, List<String>>>> pfiToExchangeIdsState,
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
              onPressed: () async => _getExchanges(ref, pfiToExchangeIdsState),
              child: Text(Loc.of(context).tapToRetry),
            ),
          ],
        ),
      );

  void _getExchanges(
    WidgetRef ref,
    ValueNotifier<AsyncValue<Map<Pfi, List<String>>>> state,
  ) {
    state.value = const AsyncLoading();
    ref
        .read(tbdexServiceProvider)
        .getExchanges(ref.read(didProvider), ref.read(pfisProvider))
        .then((exchangeIds) => state.value = AsyncData(exchangeIds))
        .catchError((error, stackTrace) {
      state.value = AsyncError(error, stackTrace);
      throw error;
    });
  }
}
