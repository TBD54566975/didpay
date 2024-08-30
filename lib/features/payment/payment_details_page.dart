import 'package:collection/collection.dart';
import 'package:didpay/features/dap/dap_state.dart';
import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/kcc/kcc_consent_page.dart';
import 'package:didpay/features/payment/payment_details_state.dart';
import 'package:didpay/features/payment/payment_method.dart';
import 'package:didpay/features/payment/payment_review_page.dart';
import 'package:didpay/features/payment/payment_selection_page.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/tbdex/tbdex_quote_notifier.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/features/vcs/vcs_notifier.dart';
import 'package:didpay/features/vcs/vcs_service.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/error_message.dart';
import 'package:didpay/shared/header.dart';
import 'package:didpay/shared/json_schema_form.dart';
import 'package:didpay/shared/loading_message.dart';
import 'package:didpay/shared/modal/modal_flow.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

class PaymentDetailsPage extends HookConsumerWidget {
  final PaymentState paymentState;
  final DapState? dapState;

  const PaymentDetailsPage({
    required this.paymentState,
    this.dapState,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quote = useState<AsyncValue<Quote?>?>(null);
    final state = useState<PaymentDetailsState>(
      paymentState.paymentDetailsState ?? PaymentDetailsState(),
    );

    final availableMethods =
        state.value.filterPaymentMethods(state.value.selectedPaymentType);

    useEffect(
      () {
        final selectedMethod = (availableMethods?.length ?? 0) <= 1
            ? availableMethods?.firstOrNull
            : null;

        state.value = state.value.copyWith(
          selectedPaymentMethod: selectedMethod,
          paymentName: selectedMethod?.title,
          resetSelectedPaymentMethod: selectedMethod == null,
        );

        return;
      },
      [state.value.selectedPaymentType],
    );

    final isAwaiting = quote.value?.isLoading ?? false;

    return PopScope(
      canPop: !isAwaiting,
      onPopInvoked: (_) {
        if (isAwaiting) {
          ref.read(quoteProvider.notifier).stopPolling();
          quote.value = null;
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: quote.value != null
              ? quote.value!.when(
                  data: (_) => Container(),
                  loading: () => LoadingMessage(
                    message: Loc.of(context).fetchingYourQuote,
                  ),
                  error: (error, _) => ErrorMessage(
                    message: error.toString(),
                    onRetry: () => _sendRfq(
                      context,
                      ref,
                      state,
                      quote,
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Header(
                      title:
                          paymentState.transactionType == TransactionType.send
                              ? dapState?.moneyAddresses != null
                                  ? Loc.of(context).checkTheirPaymentDetails
                                  : Loc.of(context).enterTheirPaymentDetails
                              : Loc.of(context).enterYourPaymentDetails,
                      subtitle: Loc.of(context).makeSureInfoIsCorrect,
                    ),
                    if (state.value.hasMultiplePaymentTypes)
                      _buildPaymentTypeSelector(
                        context,
                        state,
                      ),
                    if (!state.value.hasMultiplePaymentTypes ||
                        state.value.selectedPaymentType != null)
                      _buildPaymentMethodSelector(
                        context,
                        availableMethods,
                        state,
                      ),
                    _buildPaymentForm(context, ref, quote, state),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildPaymentForm(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<AsyncValue<Quote?>?> quote,
    ValueNotifier<PaymentDetailsState> state,
  ) =>
      Expanded(
        child: JsonSchemaForm(
          state: state.value,
          dapState: dapState,
          onSubmit: (formData) async {
            quote.value = const AsyncLoading();
            state.value = state.value.copyWith(formData: formData);

            final presentationDefinition = paymentState
                .paymentAmountState?.selectedOffering?.data.requiredClaims;

            if (presentationDefinition != null) {
              var credentials =
                  ref.read(vcsServiceProvider).getRequiredCredentials(
                        presentationDefinition,
                        ref.read(vcsProvider),
                      );

              if (credentials == null) {
                final issuedCredential = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ModalFlow(
                      initialWidget: KccConsentPage(
                        pfi: Pfi(
                          did: paymentState.paymentAmountState?.pfiDid ?? '',
                        ),
                        presentationDefinition: presentationDefinition,
                      ),
                    ),
                    fullscreenDialog: true,
                  ),
                );

                if (issuedCredential == null) return;

                credentials = [issuedCredential as String];
              }

              state.value = state.value.copyWith(credentialsJwt: credentials);
            }

            if (context.mounted) {
              await _sendRfq(
                context,
                ref,
                state,
                quote,
              );
            }

            if (context.mounted && quote.value != null) {
              await _pollForQuote(
                context,
                ref,
                state.value,
                quote,
              );
            }
          },
        ),
      );

  Widget _buildPaymentTypeSelector(
    BuildContext context,
    ValueNotifier<PaymentDetailsState> state,
  ) =>
      Column(
        children: [
          const SizedBox(height: Grid.xxs),
          ListTile(
            title: Text(
              state.value.selectedPaymentType == null
                  ? Loc.of(context).selectPaymentType
                  : state.value.selectedPaymentType ?? '',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PaymentSelectionPage(
                    state: state,
                    isSelectingMethod: false,
                  ),
                ),
              );
            },
          ),
        ],
      );

  Widget _buildPaymentMethodSelector(
    BuildContext context,
    List<PaymentMethod>? availableMethods,
    ValueNotifier<PaymentDetailsState> state,
  ) {
    final isSelectionDisabled = (availableMethods?.length ?? 0) <= 1;
    final fee = double.tryParse(
          state.value.selectedPaymentMethod?.fee ?? '0.00',
        )?.toStringAsFixed(2) ??
        '0.00';

    if (isSelectionDisabled) {
      state.value = state.value
          .copyWith(selectedPaymentMethod: availableMethods?.firstOrNull);
    }

    return Column(
      children: [
        const SizedBox(height: Grid.xxs),
        ListTile(
          title: Text(
            state.value.selectedPaymentMethod?.title ??
                Loc.of(context).selectPaymentMethod,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          subtitle: Text(
            state.value.selectedPaymentMethod?.kind == null
                ? Loc.of(context).serviceFeesMayApply
                : Loc.of(context).serviceFeeAmount(
                    fee,
                    paymentState.paymentAmountState?.payinCurrency ?? '',
                  ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing:
              isSelectionDisabled ? null : const Icon(Icons.chevron_right),
          onTap: isSelectionDisabled
              ? null
              : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PaymentSelectionPage(
                        state: state,
                        availableMethods: availableMethods,
                      ),
                    ),
                  );
                },
        ),
      ],
    );
  }

  Future<void> _sendRfq(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<PaymentDetailsState> state,
    ValueNotifier<AsyncValue<Quote?>?> quote,
  ) async {
    try {
      final updatedPaymentState =
          paymentState.copyWith(paymentDetailsState: state.value);

      final sentRfq = await ref.read(tbdexServiceProvider).sendRfq(
            ref.read(didProvider),
            paymentState.paymentAmountState?.pfiDid ?? '',
            paymentState.paymentAmountState?.offeringId ?? '',
            paymentState.paymentAmountState?.payinAmount ?? '',
            updatedPaymentState.selectedPayinKind ?? '',
            updatedPaymentState.selectedPayoutKind ?? '',
            updatedPaymentState.payinDetails,
            updatedPaymentState.payoutDetails,
            claims: state.value.credentialsJwt,
          );

      state.value = state.value.copyWith(exchangeId: sentRfq.metadata.id);
    } on Exception catch (e) {
      quote.value = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> _pollForQuote(
    BuildContext context,
    WidgetRef ref,
    PaymentDetailsState state,
    ValueNotifier<AsyncValue<Quote?>?> quote,
  ) async {
    quote.value = const AsyncLoading();
    final quoteNotifier = ref.read(quoteProvider.notifier);

    try {
      final fetchedQuote = await quoteNotifier.startPolling(
        paymentState.paymentAmountState?.pfiDid ?? '',
        state.exchangeId ?? '',
      );

      if (context.mounted) {
        quoteNotifier.stopPolling();

        if (fetchedQuote != null && quote.value != null) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PaymentReviewPage(
                paymentState: paymentState.copyWith(
                  paymentDetailsState: state.copyWith(quote: fetchedQuote),
                ),
              ),
            ),
          );
        }

        if (context.mounted) {
          quote.value = null;
        }
      }
    } on Exception catch (e) {
      if (context.mounted) {
        quoteNotifier.stopPolling();
        quote.value = AsyncError(e, StackTrace.current);
      }
    }
  }
}
