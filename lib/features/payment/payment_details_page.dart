import 'package:collection/collection.dart';
import 'package:didpay/features/did/did_provider.dart';
// import 'package:didpay/features/kcc/kcc_consent_page.dart';
import 'package:didpay/features/payment/payment_method_operations.dart';
import 'package:didpay/features/payment/payment_methods_page.dart';
import 'package:didpay/features/payment/payment_review_page.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/payment/payment_types_page.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/transaction/transaction.dart';
// import 'package:didpay/features/vcs/vcs_notifier.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/error_message.dart';
import 'package:didpay/shared/header.dart';
import 'package:didpay/shared/json_schema_form.dart';
import 'package:didpay/shared/loading_message.dart';
// import 'package:didpay/shared/modal/modal_flow.dart';
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
    final selectedPaymentMethod = useState<Object?>(null);
    final selectedPaymentType = useState<String?>(null);
    final offeringCredentials = useState<List<String>?>(null);
    final rfq = useState<AsyncValue<Rfq>?>(null);

    final paymentMethods = _getPaymentMethods(paymentState);
    final paymentTypes = _getPaymentTypes(paymentMethods);
    final filteredPaymentMethods =
        _getFilteredPaymentMethods(paymentMethods, selectedPaymentType.value);

    useEffect(
      () {
        paymentState.dap != null
            ? Future.microtask(
                () async => _sendRfq(context, ref, paymentState, rfq),
              )
            : selectedPaymentMethod.value =
                (filteredPaymentMethods?.length ?? 0) <= 1
                    ? filteredPaymentMethods?.firstOrNull
                    : null;
        return;
      },
      [selectedPaymentType.value],
    );

    final shouldShowPaymentTypeSelector = (paymentTypes.length) > 1;
    final shouldShowPaymentMethodSelector =
        !shouldShowPaymentTypeSelector || selectedPaymentType.value != null;

    return Scaffold(
      appBar: rfq.value?.isLoading ?? false ? null : AppBar(),
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
                    paymentState,
                    rfq,
                    claims: offeringCredentials.value,
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Header(
                    title: paymentState.transactionType == TransactionType.send
                        ? Loc.of(context).enterTheirPaymentDetails
                        : Loc.of(context).enterYourPaymentDetails,
                    subtitle: Loc.of(context).makeSureInfoIsCorrect,
                  ),
                  if (shouldShowPaymentTypeSelector)
                    _buildPaymentTypeSelector(
                      context,
                      selectedPaymentType,
                      paymentTypes,
                    ),
                  if (shouldShowPaymentMethodSelector)
                    _buildPaymentMethodSelector(
                      context,
                      selectedPaymentMethod,
                      filteredPaymentMethods,
                    ),
                  _buildPaymentForm(
                    context,
                    paymentState.copyWith(
                      selectedPayinMethod: paymentState.transactionType ==
                              TransactionType.deposit
                          ? selectedPaymentMethod.value as PayinMethod?
                          : null,
                      selectedPayoutMethod: paymentState.transactionType ==
                              TransactionType.deposit
                          ? null
                          : selectedPaymentMethod.value as PayoutMethod?,
                    ),
                    onPaymentFormSubmit: (paymentState) async {
                      await _sendRfq(
                        context,
                        ref,
                        paymentState,
                        rfq,
                        claims: offeringCredentials.value,
                      );
                      // TODO(ethan-tbd): uncomment below to initiate KCC flow
                      // await _hasRequiredVc(
                      //   context,
                      //   ref,
                      //   paymentState,
                      //   offeringCredentials,
                      // ).then(
                      //   (hasRequiredVc) async => !hasRequiredVc
                      //       ? null
                      //       : _sendRfq(
                      //           context,
                      //           ref,
                      //           paymentState,
                      //           rfq,
                      //           claims: offeringCredentials.value,
                      //         ),
                      // );
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPaymentForm(
    BuildContext context,
    PaymentState paymentState, {
    required void Function(PaymentState) onPaymentFormSubmit,
  }) {
    final paymentMethod =
        paymentState.transactionType == TransactionType.deposit
            ? paymentState.selectedPayinMethod
            : paymentState.selectedPayoutMethod;

    final isDisabled = paymentMethod.isDisabled;
    final schema = paymentMethod.paymentSchema;
    final fee = paymentMethod.paymentFee;
    final paymentName = paymentMethod.paymentName;

    return Expanded(
      child: JsonSchemaForm(
        schema: schema,
        isDisabled: isDisabled,
        onSubmit: (formData) => onPaymentFormSubmit(
          paymentState.copyWith(
            serviceFee: fee,
            paymentName: paymentName,
            formData: formData,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentTypeSelector(
    BuildContext context,
    ValueNotifier<String?> selectedPaymentType,
    Set<String> paymentTypes,
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
                    paymentTypes: paymentTypes,
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
    ValueNotifier<Object?> selectedPaymentMethod,
    List<Object?>? filteredPaymentMethods,
  ) {
    final isSelectionDisabled = (filteredPaymentMethods?.length ?? 0) <= 1;
    final fee = double.tryParse(
          selectedPaymentMethod.value?.paymentFee ?? '0.00',
        )?.toStringAsFixed(2) ??
        '0.00';

    if (isSelectionDisabled) {
      selectedPaymentMethod.value = filteredPaymentMethods?.firstOrNull;
    }

    return Column(
      children: [
        const SizedBox(height: Grid.xxs),
        ListTile(
          title: Text(
            selectedPaymentMethod.value.paymentName ??
                Loc.of(context).selectPaymentMethod,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          subtitle: Text(
            selectedPaymentMethod.value.paymentName == null
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
                        paymentMethods: filteredPaymentMethods,
                      ),
                    ),
                  );
                },
        ),
      ],
    );
  }

  List<Object?>? _getPaymentMethods(PaymentState paymentState) =>
      paymentState.transactionType == TransactionType.deposit
          ? paymentState.payinMethods
          : paymentState.payoutMethods;

  Set<String> _getPaymentTypes(List<Object?>? paymentMethods) =>
      paymentMethods
          ?.map((method) => method.paymentGroup)
          .whereType<String>()
          .toSet() ??
      {};

  List<Object?>? _getFilteredPaymentMethods(
    List<Object?>? paymentMethods,
    String? selectedPaymentType,
  ) =>
      paymentMethods
          ?.where(
            (method) =>
                method.paymentGroup?.contains(selectedPaymentType ?? '') ??
                true,
          )
          .toList();

  Future<void> _sendRfq(
    BuildContext context,
    WidgetRef ref,
    PaymentState paymentState,
    ValueNotifier<AsyncValue<Rfq>?> state, {
    List<String>? claims,
  }) async {
    state.value = const AsyncLoading();

    try {
      await ref
          .read(tbdexServiceProvider)
          .sendRfq(
            ref.read(didProvider),
            paymentState.copyWith(claims: claims),
          )
          .then(
            (rfq) async => Navigator.of(context)
                .push(
              MaterialPageRoute(
                builder: (context) => PaymentReviewPage(
                  paymentState: paymentState.copyWith(
                    exchangeId: rfq.metadata.id,
                    claims: claims,
                  ),
                ),
              ),
            )
                .then((_) {
              if (context.mounted) state.value = null;
            }),
          );
    } on Exception catch (e) {
      state.value = AsyncError(e, StackTrace.current);
    }
  }

  // Future<bool> _hasRequiredVc(
  //   BuildContext context,
  //   WidgetRef ref,
  //   PaymentState paymentState,
  //   ValueNotifier<List<String>?> offeringCredentials,
  // ) async {
  //   final presentationDefinition =
  //       paymentState.selectedOffering?.data.requiredClaims;
  //   final credentials =
  //       presentationDefinition?.selectCredentials(ref.read(vcsProvider));

  //   if (credentials == null && presentationDefinition == null) {
  //     return true;
  //   }

  //   if (credentials != null && credentials.isNotEmpty) {
  //     offeringCredentials.value = credentials;
  //     return true;
  //   }

  //   final issuedCredential = await Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => ModalFlow(
  //         initialWidget: KccConsentPage(pfi: paymentState.selectedPfi!),
  //       ),
  //       fullscreenDialog: true,
  //     ),
  //   );

  //   if (issuedCredential == null) return false;

  //   offeringCredentials.value = [issuedCredential as String];
  //   return true;
  // }
}
