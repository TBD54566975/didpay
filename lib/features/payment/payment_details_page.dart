import 'package:collection/collection.dart';
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
  final String transactionType;

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

    // TODO: remove this when tbdex issue #233 is resolved
    final paymentTypes = paymentMethods
        ?.map((method) => method.kind.split('_').firstOrNull)
        .toSet();

    final selectedPaymentMethod = useState<PaymentMethod?>(null);
    final selectedPaymentType = useState(paymentTypes?.firstOrNull);

    final filteredPaymentMethods = paymentMethods
        ?.where(
          (method) => method.kind.contains(selectedPaymentType.value ?? ''),
        )
        .toList();

    useEffect(
      () {
        selectedPaymentMethod.value = null;
        return;
      },
      [selectedPaymentType.value],
    );

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (paymentTypes != null && paymentTypes.length > 1)
              _buildPaymentTypeSegments(
                context,
                paymentTypes,
                selectedPaymentType,
              ),
            _buildHeader(
              context,
              Loc.of(context).enterYourPaymentChannelDetails(
                selectedPaymentType.value?.toLowerCase() ?? '',
              ),
            ),
            const SizedBox(height: Grid.xs),
            _buildPaymentMethodTile(
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

  Widget _buildPaymentTypeSegments(
    BuildContext context,
    Set<String?> paymentTypes,
    ValueNotifier<String?> selectedPaymentType,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Grid.side),
      child: SegmentedButton(
        segments: paymentTypes
            .map(
              (segment) => ButtonSegment(
                value: segment,
                label: Text(
                  segment ?? '',
                  style: TextStyle(
                    color: selectedPaymentType.value == segment
                        ? Theme.of(context).colorScheme.onSecondary
                        : Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            )
            .toList(),
        selected: {selectedPaymentType.value},
        showSelectedIcon: false,
        onSelectionChanged: (type) {
          selectedPaymentType.value = type.firstOrNull;
        },
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

  Widget _buildPaymentMethodTile(
    BuildContext context,
    ValueNotifier<PaymentMethod?> selectedPaymentMethod,
    List<PaymentMethod>? filteredPaymentMethods,
  ) {
    final paymentName = selectedPaymentMethod.value?.kind.split('_').lastOrNull;
    final fee = (double.tryParse(selectedPaymentMethod.value?.fee ?? '0.00')
            ?.toStringAsFixed(2) ??
        '0.00');

    return ListTile(
      title: Text(
        paymentName ?? Loc.of(context).selectPaymentMethod,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
      subtitle: Text(
        paymentName == null
            ? Loc.of(context).serviceFeesMayApply
            : Loc.of(context).serviceFeeAmount(fee, 'USD'),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SearchPaymentMethodsPage(
              selectedPaymentMethod: selectedPaymentMethod,
              paymentMethods: filteredPaymentMethods,
            ),
          ),
        );
      },
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
                        serviceFee: selectedPaymentMethod.value!.fee ?? '0.00',
                        transactionType: transactionType,
                        paymentName: selectedPaymentMethod.value!.kind
                                .split('_')
                                .lastOrNull ??
                            '',
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
