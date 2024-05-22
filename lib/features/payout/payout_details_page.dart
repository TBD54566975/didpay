import 'package:collection/collection.dart';
import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/payment/payment_details.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/payment/review_payment_page.dart';
import 'package:didpay/features/payment/search_payment_types_page.dart';
import 'package:didpay/features/payout/search_payout_methods_page.dart';
import 'package:didpay/features/tbdex/rfq_state.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/async_error_widget.dart';
import 'package:didpay/shared/async_loading_widget.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

class PayoutDetailsPage extends HookConsumerWidget {
  final RfqState rfqState;
  final PaymentState paymentState;

  const PayoutDetailsPage({
    required this.rfqState,
    required this.paymentState,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sendRfqState = useState<AsyncValue<Rfq>?>(null);

    final payoutTypes = paymentState.payoutMethods
        ?.map((method) => method.group)
        .whereType<String>()
        .toSet();

    final selectedPayoutType = useState<String?>(null);
    final selectedPayoutMethod = useState<PayoutMethod?>(null);

    final filteredPayoutMethods = paymentState.payoutMethods
        ?.where(
          (method) =>
              method.group?.contains(selectedPayoutType.value ?? '') ?? true,
        )
        .toList();

    useEffect(
      () {
        selectedPayoutMethod.value = (filteredPayoutMethods?.length ?? 1) <= 1
            ? selectedPayoutMethod.value = filteredPayoutMethods?.firstOrNull
            : null;
        return;
      },
      [selectedPayoutType.value],
    );

    final shouldShowPayoutTypeSelector = (payoutTypes?.length ?? 0) > 1;
    final shouldShowPayoutMethodSelector =
        !shouldShowPayoutTypeSelector || selectedPayoutType.value != null;

    final headerTitle = paymentState.transactionType == TransactionType.send
        ? Loc.of(context).enterTheirPaymentDetails
        : Loc.of(context).enterYourPaymentDetails;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: sendRfqState.value != null
            ? sendRfqState.value!.when(
                data: (rfq) =>
                    AsyncLoadingWidget(text: Loc.of(context).gettingYourQuote),
                loading: () => AsyncLoadingWidget(
                  text: Loc.of(context).sendingYourRequest,
                ),
                error: (error, _) => AsyncErrorWidget(
                  text: error.toString(),
                  onRetry: () =>
                      // TODO(ethan-tbd): may not have updated paymentState here..
                      _sendRfq(context, ref, sendRfqState, paymentState),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(
                    context,
                    headerTitle,
                  ),
                  if (shouldShowPayoutTypeSelector)
                    _buildPayoutTypeSelector(
                      context,
                      selectedPayoutType,
                      payoutTypes,
                    ),
                  if (shouldShowPayoutMethodSelector)
                    _buildPayoutMethodSelector(
                      context,
                      selectedPayoutMethod,
                      filteredPayoutMethods,
                    ),
                  PaymentDetails.buildForm(
                    context,
                    rfqState.copyWith(payoutMethod: selectedPayoutMethod.value),
                    paymentState,
                    onPaymentSubmit: (paymentState) =>
                        _sendRfq(context, ref, sendRfqState, paymentState),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Grid.side,
          vertical: Grid.xs,
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: Grid.xs),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                Loc.of(context).makeSureInfoIsCorrect,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );

  Widget _buildPayoutTypeSelector(
    BuildContext context,
    ValueNotifier<String?> selectedPayoutType,
    Set<String?>? payoutTypes,
  ) =>
      Column(
        children: [
          const SizedBox(height: Grid.xxs),
          ListTile(
            title: Text(
              selectedPayoutType.value == null
                  ? Loc.of(context).selectPaymentType
                  : selectedPayoutType.value ?? '',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SearchPaymentTypesPage(
                    selectedPaymentType: selectedPayoutType,
                    paymentTypes: payoutTypes,
                    payinCurrency: paymentState.payinCurrency,
                  ),
                ),
              );
            },
          ),
        ],
      );

  Widget _buildPayoutMethodSelector(
    BuildContext context,
    ValueNotifier<PayoutMethod?> selectedPayoutMethod,
    List<PayoutMethod>? filteredPayoutMethods,
  ) {
    final isSelectionDisabled = (filteredPayoutMethods?.length ?? 0) <= 1;
    final fee = double.tryParse(selectedPayoutMethod.value?.fee ?? '0.00')
            ?.toStringAsFixed(2) ??
        '0.00';

    if (isSelectionDisabled) {
      selectedPayoutMethod.value = filteredPayoutMethods?.firstOrNull;
    }

    return Column(
      children: [
        const SizedBox(height: Grid.xxs),
        ListTile(
          title: Text(
            selectedPayoutMethod.value == null
                ? Loc.of(context).selectPaymentMethod
                : selectedPayoutMethod.value?.name ??
                    selectedPayoutMethod.value?.kind ??
                    '',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          subtitle: Text(
            selectedPayoutMethod.value?.name == null
                ? Loc.of(context).serviceFeesMayApply
                : Loc.of(context)
                    .serviceFeeAmount(fee, paymentState.payinCurrency),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing:
              isSelectionDisabled ? null : const Icon(Icons.chevron_right),
          onTap: isSelectionDisabled
              ? null
              : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SearchPayoutMethodsPage(
                        payoutCurrency: paymentState.payinCurrency,
                        selectedPayoutMethod: selectedPayoutMethod,
                        payoutMethods: filteredPayoutMethods,
                      ),
                    ),
                  );
                },
        ),
      ],
    );
  }

  void _sendRfq(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<AsyncValue<Rfq>?> state,
    PaymentState paymentState,
  ) {
    state.value = const AsyncLoading();
    ref
        .read(tbdexServiceProvider)
        .sendRfq(ref.read(didProvider), paymentState.pfi, rfqState)
        .then((rfq) async {
      state.value = AsyncData(rfq);
      await Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (context) => ReviewPaymentPage(
                exchangeId: rfq.metadata.id,
                paymentState: paymentState,
              ),
            ),
          )
          .then((_) => state.value = null);
    }).catchError((error, stackTrace) {
      state.value = AsyncError(error.toString(), stackTrace);
      throw error;
    });
  }
}
