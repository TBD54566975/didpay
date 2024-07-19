import 'package:collection/collection.dart';
import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/kcc/kcc_consent_page.dart';
import 'package:didpay/features/payment/payment_details_state.dart';
import 'package:didpay/features/payment/payment_method.dart';
import 'package:didpay/features/payment/payment_methods_page.dart';
import 'package:didpay/features/payment/payment_review_page.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/payment/payment_types_page.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/features/vcs/vcs_notifier.dart';
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

  const PaymentDetailsPage({
    required this.paymentState,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rfq = useState<AsyncValue<Rfq>?>(null);
    final state = useState<PaymentDetailsState>(
      paymentState.paymentDetailsState ?? PaymentDetailsState(),
    );
    final availableMethods =
        state.value.filterPaymentMethods(state.value.selectedPaymentType);

    useEffect(
      () {
        if (state.value.moneyAddresses != null) {
          state.value =
              state.value.copyWith(formData: paymentState.payoutDetails);
        } else {
          final selectedMethod = (availableMethods?.length ?? 0) <= 1
              ? availableMethods?.firstOrNull
              : null;

          state.value = state.value.copyWith(
            selectedPaymentMethod: selectedMethod,
            paymentName: selectedMethod?.title,
          );
        }

        return;
      },
      [state.value.selectedPaymentType],
    );

    final isSendingRfq = rfq.value?.isLoading ?? false;

    return PopScope(
      canPop: !isSendingRfq,
      onPopInvoked: (_) {
        if (isSendingRfq) rfq.value = null;
      },
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: rfq.value != null
              ? rfq.value!.when(
                  data: (_) => Container(),
                  loading: () => LoadingMessage(
                    message: Loc.of(context).sendingYourRequest,
                  ),
                  error: (error, _) => ErrorMessage(
                    message: error.toString(),
                    onRetry: () => _sendRfq(
                      context,
                      ref,
                      state.value,
                      rfq,
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Header(
                      title:
                          paymentState.transactionType == TransactionType.send
                              ? state.value.moneyAddresses != null
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
                    if (state.value.hasNoPaymentTypes ||
                        state.value.selectedPaymentType != null)
                      _buildPaymentMethodSelector(
                        context,
                        availableMethods,
                        state,
                      ),
                    _buildPaymentForm(
                      context,
                      ref,
                      state,
                      rfq,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildPaymentForm(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<PaymentDetailsState> state,
    ValueNotifier<AsyncValue<Rfq>?> rfq,
  ) =>
      Expanded(
        child: JsonSchemaForm(
          state: state.value,
          onSubmit: (formData) {
            state.value = state.value.copyWith(formData: formData);
            _checkCredsAndSendRfq(
              context,
              ref,
              rfq,
              state,
            );
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
                  builder: (context) => PaymentTypesPage(state: state),
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
                      builder: (context) => PaymentMethodsPage(
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

  Future<void> _checkCredsAndSendRfq(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<AsyncValue<Rfq>?> rfq,
    ValueNotifier<PaymentDetailsState> state,
  ) async {
    final hasRequiredVc = await _hasRequiredVc(context, ref, state);

    if (hasRequiredVc && context.mounted) {
      await _sendRfq(
        context,
        ref,
        state.value,
        rfq,
      );
    }
  }

  Future<void> _sendRfq(
    BuildContext context,
    WidgetRef ref,
    PaymentDetailsState state,
    ValueNotifier<AsyncValue<Rfq>?> rfq,
  ) async {
    rfq.value = const AsyncLoading();

    try {
      final updatedPaymentState =
          paymentState.copyWith(paymentDetailsState: state);

      final sentRfq = await ref.read(tbdexServiceProvider).sendRfq(
            ref.read(didProvider),
            updatedPaymentState.paymentAmountState?.pfiDid ?? '',
            updatedPaymentState.paymentAmountState?.offeringId ?? '',
            updatedPaymentState.paymentAmountState?.payinAmount ?? '',
            updatedPaymentState.selectedPayinKind ?? '',
            updatedPaymentState.selectedPayoutKind ?? '',
            updatedPaymentState.payinDetails,
            updatedPaymentState.payoutDetails,
            claims: updatedPaymentState.paymentDetailsState?.credentialsJwt,
          );

      if (context.mounted && rfq.value != null) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentReviewPage(
              paymentState: updatedPaymentState.copyWith(
                paymentDetailsState: updatedPaymentState.paymentDetailsState
                    ?.copyWith(exchangeId: sentRfq.metadata.exchangeId),
              ),
            ),
          ),
        );

        if (context.mounted) rfq.value = null;
      }
    } on Exception catch (e) {
      rfq.value = AsyncError(e, StackTrace.current);
    }
  }

  Future<bool> _hasRequiredVc(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<PaymentDetailsState> state,
  ) async {
    final presentationDefinition =
        paymentState.paymentAmountState?.selectedOffering?.data.requiredClaims;
    final credentials =
        presentationDefinition?.selectCredentials(ref.read(vcsProvider));

    if (credentials == null && presentationDefinition == null) {
      return true;
    }

    if (credentials != null && credentials.isNotEmpty) {
      state.value = state.value.copyWith(credentialsJwt: credentials);
      return true;
    }

    if (paymentState.paymentAmountState?.pfiDid == null) return false;

    final issuedCredential = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ModalFlow(
          initialWidget: KccConsentPage(
            pfi: Pfi(did: paymentState.paymentAmountState?.pfiDid ?? ''),
          ),
        ),
        fullscreenDialog: true,
      ),
    );

    if (issuedCredential == null) return false;

    state.value =
        state.value.copyWith(credentialsJwt: [issuedCredential as String]);
    return true;
  }
}
