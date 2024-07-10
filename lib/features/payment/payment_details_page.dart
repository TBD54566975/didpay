import 'package:collection/collection.dart';
import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/kcc/kcc_consent_page.dart';
import 'package:didpay/features/payment/payment_details_state.dart';
import 'package:didpay/features/payment/payment_methods_page.dart';
import 'package:didpay/features/payment/payment_review_page.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/payment/payment_types_page.dart';
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
  final PaymentDetailsState paymentDetailsState;

  const PaymentDetailsPage({
    required this.paymentState,
    required this.paymentDetailsState,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPaymentMethod = useState<PaymentMethod?>(null);
    final selectedPaymentType = useState<String?>(null);
    final offeringCredentials = useState<List<String>?>(null);
    final rfq = useState<AsyncValue<Rfq>?>(null);

    final availableMethods =
        paymentDetailsState.filterPaymentMethods(selectedPaymentType.value);

    useEffect(
      () {
        if (paymentState.dap != null) {
          Future.microtask(
            () async => _checkCredsAndSendRfq(
              context,
              ref,
              selectedPaymentMethod.value,
              offeringCredentials,
              rfq,
            ),
          );
        } else {
          selectedPaymentMethod.value = (availableMethods?.length ?? 0) <= 1
              ? availableMethods?.firstOrNull
              : null;
        }

        return;
      },
      [selectedPaymentType.value],
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
                              ? Loc.of(context).enterTheirPaymentDetails
                              : Loc.of(context).enterYourPaymentDetails,
                      subtitle: Loc.of(context).makeSureInfoIsCorrect,
                    ),
                    if (paymentDetailsState.hasMultiplePaymentTypes)
                      _buildPaymentTypeSelector(
                        context,
                        selectedPaymentType,
                      ),
                    if (paymentDetailsState.hasNoPaymentTypes ||
                        selectedPaymentType.value != null)
                      _buildPaymentMethodSelector(
                        context,
                        availableMethods,
                        selectedPaymentMethod,
                      ),
                    _buildPaymentForm(
                      context,
                      ref,
                      selectedPaymentMethod.value,
                      offeringCredentials,
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
    PaymentMethod? paymentMethod,
    ValueNotifier<List<String>?> offeringCredentials,
    ValueNotifier<AsyncValue<Rfq>?> rfq,
  ) {
    final isDisabled = paymentMethod == null;

    return Expanded(
      child: JsonSchemaForm(
        schema: paymentMethod?.schema,
        isDisabled: isDisabled,
        onSubmit: (formData) {
          _checkCredsAndSendRfq(
            context,
            ref,
            paymentMethod,
            offeringCredentials,
            rfq,
            formData: formData,
          );
        },
      ),
    );
  }

  Widget _buildPaymentTypeSelector(
    BuildContext context,
    ValueNotifier<String?> selectedPaymentType,
  ) =>
      Column(
        children: [
          const SizedBox(height: Grid.xxs),
          ListTile(
            title: Text(
              selectedPaymentType.value == null
                  ? Loc.of(context).selectPaymentType
                  : selectedPaymentType.value ?? '',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PaymentTypesPage(
                    payinCurrency: paymentState.payinCurrency,
                    paymentTypes: paymentDetailsState.paymentTypes,
                    selectedPaymentType: selectedPaymentType,
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
    ValueNotifier<PaymentMethod?> selectedPaymentMethod,
  ) {
    final isSelectionDisabled = (availableMethods?.length ?? 0) <= 1;
    final fee = double.tryParse(
          selectedPaymentMethod.value?.fee ?? '0.00',
        )?.toStringAsFixed(2) ??
        '0.00';

    if (isSelectionDisabled) {
      selectedPaymentMethod.value = availableMethods?.firstOrNull;
    }

    return Column(
      children: [
        const SizedBox(height: Grid.xxs),
        ListTile(
          title: Text(
            selectedPaymentMethod.value?.name ??
                selectedPaymentMethod.value?.kind ??
                Loc.of(context).selectPaymentMethod,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          subtitle: Text(
            selectedPaymentMethod.value?.kind == null
                ? Loc.of(context).serviceFeesMayApply
                : Loc.of(context)
                    .serviceFeeAmount(fee, paymentState.payinCurrency ?? ''),
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
                        paymentCurrency: paymentState.transactionType ==
                                TransactionType.deposit
                            ? paymentState.payinCurrency
                            : paymentState.payoutCurrency,
                        selectedPaymentMethod: selectedPaymentMethod,
                        paymentMethods: availableMethods,
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
    paymentMethod,
    ValueNotifier<List<String>?> offeringCredentials,
    ValueNotifier<AsyncValue<Rfq>?> state, {
    Map<String, String>? formData,
  }) async {
    final hasRequiredVc = await _hasRequiredVc(
      context,
      ref,
      offeringCredentials,
    );

    if (hasRequiredVc && context.mounted) {
      await _sendRfq(
        context,
        ref,
        state,
      );
    }
  }

  Future<void> _sendRfq(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<AsyncValue<Rfq>?> state,
  ) async {
    state.value = const AsyncLoading();

    try {
      await ref.read(tbdexServiceProvider).sendRfq(
            ref.read(didProvider),
            paymentState.rfq,
          );

      if (context.mounted && state.value != null) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentReviewPage(paymentState: paymentState),
          ),
        );

        if (context.mounted) state.value = null;
      }
    } on Exception catch (e) {
      state.value = AsyncError(e, StackTrace.current);
    }
  }

  Future<bool> _hasRequiredVc(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<List<String>?> offeringCredentials,
  ) async {
    final presentationDefinition = paymentState.offering?.data.requiredClaims;
    final credentials =
        presentationDefinition?.selectCredentials(ref.read(vcsProvider));

    if (credentials == null && presentationDefinition == null) {
      return true;
    }

    if (credentials != null && credentials.isNotEmpty) {
      offeringCredentials.value = credentials;
      return true;
    }

    if (paymentState.pfi == null) return false;

    final issuedCredential = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ModalFlow(
          initialWidget: KccConsentPage(pfi: paymentState.pfi!),
        ),
        fullscreenDialog: true,
      ),
    );

    if (issuedCredential == null) return false;

    offeringCredentials.value = [issuedCredential as String];
    return true;
  }
}
