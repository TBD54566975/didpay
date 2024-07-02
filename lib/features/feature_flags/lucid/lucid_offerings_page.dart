import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/payment/payment_amount_page.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/error_message.dart';
import 'package:didpay/shared/header.dart';
import 'package:didpay/shared/loading_message.dart';
import 'package:didpay/shared/next_button.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

class LucidOfferingsPage extends HookConsumerWidget {
  const LucidOfferingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPfi = useState<Pfi?>(null);
    final selectedOffering = useState<Offering?>(null);
    final offerings =
        useState<AsyncValue<Map<Pfi, List<Offering>>>>(const AsyncLoading());

    useEffect(
      () {
        Future.microtask(() async => _getOfferings(context, ref, offerings));
        return null;
      },
      [],
    );

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: offerings.value.when(
          data: (offeringsMap) {
            final offerings = offeringsMap.entries
                .expand(
                  (entry) => entry.value
                      .map((offering) => MapEntry(entry.key, offering)),
                )
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Header(
                  title: Loc.of(context).lucidMode,
                  subtitle: Loc.of(context).selectFromUnfilteredList,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: offerings.length,
                    itemBuilder: (context, index) {
                      final entry = offerings[index];
                      final pfi = entry.key;
                      final offering = entry.value;
                      final isSelected = selectedOffering.value?.metadata.id ==
                          offering.metadata.id;

                      return ListTile(
                        leading: Container(
                          width: Grid.md,
                          height: Grid.md,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(Grid.xxs),
                          ),
                          child: const Center(child: Icon(Icons.attach_money)),
                        ),
                        title: Text(
                          '${offering.data.payin.currencyCode} → ${offering.data.payout.currencyCode}',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        subtitle: AutoSizeText(
                          offering.metadata.from,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                        ),
                        onTap: () {
                          selectedOffering.value = offering;
                          selectedPfi.value = pfi;
                        },
                        trailing: isSelected
                            ? Icon(
                                Icons.check,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                      );
                    },
                  ),
                ),
                NextButton(
                  onPressed: selectedOffering.value == null
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PaymentAmountPage(
                                paymentState: PaymentState(
                                  transactionType: TransactionType.send,
                                  selectedOffering: selectedOffering.value,
                                  selectedPfi: selectedPfi.value,
                                  offeringsMap: offeringsMap,
                                ),
                              ),
                            ),
                          ),
                ),
              ],
            );
          },
          loading: () =>
              LoadingMessage(message: Loc.of(context).fetchingOfferings),
          error: (error, stackTrace) => ErrorMessage(
            message: error.toString(),
            onRetry: () => _getOfferings(context, ref, offerings),
          ),
        ),
      ),
    );
  }

  Future<void> _getOfferings(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<AsyncValue<Map<Pfi, List<Offering>>>> state,
  ) async {
    state.value = const AsyncLoading();
    try {
      final offerings = await ref.read(tbdexServiceProvider).getOfferings(
            const PaymentState(transactionType: TransactionType.send),
            ref.read(pfisProvider),
          );

      if (context.mounted) {
        state.value = AsyncData(offerings);
      }
    } on Exception catch (e) {
      state.value = AsyncError(e, StackTrace.current);
    }
  }
}
