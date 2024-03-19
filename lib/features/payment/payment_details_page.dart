import 'package:collection/collection.dart';
import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/features/payment/search_payment_types_page.dart';
import 'package:didpay/features/request/review_request_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:didpay/features/payment/payment_method.dart';
import 'package:didpay/features/payment/search_payment_methods_page.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/json_schema_form.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PaymentDetailsPage extends HookConsumerWidget {
  final String payinAmount;
  final String payoutAmount;
  final String payinCurrency;
  final String payoutCurrency;
  final String exchangeRate;
  final TransactionType transactionType;

  const PaymentDetailsPage({
    required this.payinAmount,
    required this.payoutAmount,
    required this.payinCurrency,
    required this.payoutCurrency,
    required this.exchangeRate,
    required this.transactionType,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentMethods = ref.watch(paymentMethodProvider);

    final paymentTypes = paymentMethods
        ?.map((method) => method.group)
        .whereType<String>()
        .toSet();

    final selectedPaymentType = useState<String?>(null);
    final selectedPaymentMethod = useState<PaymentMethod?>(null);

    final filteredPaymentMethods = paymentMethods
        ?.where(
          (method) =>
              method.group?.contains(selectedPaymentType.value ?? '') ?? true,
        )
        .toList();

    useEffect(
      () {
        selectedPaymentMethod.value = (filteredPaymentMethods?.length ?? 0) <= 1
            ? selectedPaymentMethod.value = filteredPaymentMethods?.firstOrNull
            : null;
        return;
      },
      [selectedPaymentType.value],
    );

    final bool shouldShowPaymentTypeTile =
        paymentTypes != null && paymentTypes.length > 1;
    final bool shouldShowPaymentMethodTile =
        (paymentTypes == null || paymentTypes.length <= 1) ||
            selectedPaymentType.value != null;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(
              context,
              Loc.of(context).enterYourPaymentDetails,
            ),
            if (shouldShowPaymentTypeTile)
              _buildPaymentTypeSelector(
                context,
                selectedPaymentType,
                paymentTypes,
              ),
            if (shouldShowPaymentMethodTile)
              _buildPaymentMethodSelector(
                context,
                selectedPaymentMethod,
                filteredPaymentMethods,
              ),
            _buildForm(context, selectedPaymentMethod),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: Grid.side, vertical: Grid.xs),
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
  }

  Widget _buildPaymentTypeSelector(
    BuildContext context,
    ValueNotifier<String?> selectedPaymentType,
    Set<String?>? paymentTypes,
  ) {
    return Column(
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
                builder: (context) => SearchPaymentTypesPage(
                  selectedPaymentType: selectedPaymentType,
                  paymentTypes: paymentTypes,
                  payinCurrency: payinCurrency,
                ),
              ),
            );
          },
        )
      ],
    );
  }

  Widget _buildPaymentMethodSelector(
    BuildContext context,
    ValueNotifier<PaymentMethod?> selectedPaymentMethod,
    List<PaymentMethod>? filteredPaymentMethods,
  ) {
    final isSelectionDisabled = (filteredPaymentMethods?.length ?? 0) < 2;
    final fee = (double.tryParse(selectedPaymentMethod.value?.fee ?? '0.00')
            ?.toStringAsFixed(2) ??
        '0.00');

    return Column(
      children: [
        const SizedBox(height: Grid.xxs),
        ListTile(
          title: Text(
            selectedPaymentMethod.value?.name ??
                Loc.of(context).selectPaymentMethod,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          subtitle: Text(
            selectedPaymentMethod.value?.name == null
                ? Loc.of(context).serviceFeesMayApply
                : Loc.of(context).serviceFeeAmount(fee, payinCurrency),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing:
              isSelectionDisabled ? null : const Icon(Icons.chevron_right),
          onTap: isSelectionDisabled
              ? null
              : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SearchPaymentMethodsPage(
                        selectedPaymentMethod: selectedPaymentMethod,
                        paymentMethods: filteredPaymentMethods,
                        payinCurrency: payinCurrency,
                      ),
                    ),
                  );
                },
        ),
      ],
    );
  }

  Widget _buildForm(
    BuildContext context,
    ValueNotifier<PaymentMethod?> selectedPaymentMethod,
  ) {
    return selectedPaymentMethod.value == null
        ? _buildDisabledButton(context)
        : Expanded(
            child: JsonSchemaForm(
              schema: selectedPaymentMethod.value!.requiredPaymentDetails,
              onSubmit: (formData) {
                if (isValidOnSubmit(formData, selectedPaymentMethod)) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ReviewRequestPage(
                        payinAmount: payinAmount,
                        payoutAmount: payoutAmount,
                        payinCurrency: payinCurrency,
                        payoutCurrency: payoutCurrency,
                        exchangeRate: exchangeRate,
                        serviceFee: selectedPaymentMethod.value?.fee ?? '0.00',
                        transactionType: transactionType,
                        paymentName: selectedPaymentMethod.value?.name ?? '',
                        formData: formData,
                      ),
                    ),
                  );
                }
              },
            ),
          );
  }

  bool isValidOnSubmit(Map<String, String> formData,
      ValueNotifier<PaymentMethod?> selectedPaymentMethod) {
    return formData['accountNumber'] != null &&
        selectedPaymentMethod.value!.kind.split('_').lastOrNull != null;
  }

  Widget _buildDisabledButton(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: Container()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Grid.side),
            child: FilledButton(
              onPressed: null,
              child: Text(Loc.of(context).next),
            ),
          ),
        ],
      ),
    );
  }
}
