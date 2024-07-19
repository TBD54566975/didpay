import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/account/account_balance_card.dart';
import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_add_page.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/send/send_page.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/transaction/transaction_tile.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/loading_message.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pfis = ref.watch(pfisProvider);
    final exchanges =
        useState<AsyncValue<Map<Pfi, List<String>>>>(const AsyncLoading());

    useEffect(
      () {
        Future.microtask(() async => _getExchanges(context, ref, exchanges));
        return null;
      },
      [],
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AccountBalanceCard(),
            Expanded(
              child: pfis.isEmpty
                  ? _buildGetStarted(
                      context,
                      ref,
                      Loc.of(context).noPfisFound,
                      Loc.of(context).startByAddingAPfi,
                    )
                  : _buildTransactionsList(
                      context,
                      ref,
                      exchanges,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<AsyncValue<Map<Pfi, List<String>>>> state,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Grid.side,
              vertical: Grid.xs,
            ),
            child: AutoSizeText(
              Loc.of(context).activity,
              style: Theme.of(context).textTheme.bodyMedium,
              textScaleFactor: 1.1,
              maxLines: 1,
            ),
          ),
          Expanded(
            child: state.value.when(
              data: (exchangeMap) => exchangeMap.isEmpty
                  ? _buildGetStarted(
                      context,
                      ref,
                      Loc.of(context).noTransactionsYet,
                      Loc.of(context).startBySendingMoney,
                    )
                  : RefreshIndicator(
                      onRefresh: () async => _getExchanges(context, ref, state),
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
                state,
              ),
              loading: () => LoadingMessage(
                message: Loc.of(context).fetchingTransactions,
              ),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Grid.xxl),
              child: AutoSizeText(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: Grid.xxs),
              AutoSizeText(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: Grid.xs),
            FilledButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  Theme.of(context).colorScheme.secondaryContainer,
                ),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ref.read(pfisProvider).isEmpty
                      ? const PfisAddPage()
                      : const SendPage(),
                ),
              ),
              child: AutoSizeText(
                Loc.of(context).getStarted,
                maxLines: 1,
              ),
            ),
          ],
        ),
      );

  // TODO(ethan-tbd): update error state, https://github.com/TBD54566975/didpay/issues/125
  Widget _buildTransactionsError(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<AsyncValue<Map<Pfi, List<String>>>> state,
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
              onPressed: () async => _getExchanges(context, ref, state),
              child: Text(Loc.of(context).tapToRetry),
            ),
          ],
        ),
      );

  Future<void> _getExchanges(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<AsyncValue<Map<Pfi, List<String>>>> state,
  ) async {
    state.value = const AsyncLoading();
    try {
      final exchanges = await ref
          .read(tbdexServiceProvider)
          .getExchanges(ref.read(didProvider), ref.read(pfisProvider));

      if (context.mounted) {
        state.value = AsyncData(exchanges);
      }
    } on Exception catch (e) {
      if (context.mounted) {
        state.value = AsyncError(e, StackTrace.current);
      }
    }
  }
}
