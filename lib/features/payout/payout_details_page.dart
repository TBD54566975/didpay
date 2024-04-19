import 'package:collection/collection.dart';
import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/features/payment/review_payment_page.dart';
import 'package:didpay/features/payment/search_payment_types_page.dart';
import 'package:didpay/features/payout/search_payout_methods_page.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/json_schema_form.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

class PayoutDetailsPage extends HookConsumerWidget {
  final String payinAmount;
  final String payoutAmount;
  final String payinCurrency;
  final String payoutCurrency;
  final String exchangeRate;
  final String offeringId;
  final TransactionType transactionType;
  final List<PayoutMethod> payoutMethods;

  const PayoutDetailsPage({
    required this.payinAmount,
    required this.payoutAmount,
    required this.payinCurrency,
    required this.payoutCurrency,
    required this.exchangeRate,
    required this.offeringId,
    required this.transactionType,
    required this.payoutMethods,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payoutTypes =
        payoutMethods.map((method) => method.group).whereType<String>().toSet();

    final selectedPayoutType = useState<String?>(null);
    final selectedPayoutMethod = useState<PayoutMethod?>(null);

    final filteredPayoutMethods = payoutMethods
        .where(
          (method) =>
              method.group?.contains(selectedPayoutType.value ?? '') ?? true,
        )
        .toList();

    useEffect(
      () {
        selectedPayoutMethod.value = (filteredPayoutMethods.length) <= 1
            ? selectedPayoutMethod.value = filteredPayoutMethods.firstOrNull
            : null;
        return;
      },
      [selectedPayoutType.value],
    );

    final shouldShowPayoutTypeSelector = payoutTypes.length > 1;
    final shouldShowPayoutMethodSelector =
        !shouldShowPayoutTypeSelector || selectedPayoutType.value != null;

    final headerTitle = transactionType == TransactionType.send
        ? Loc.of(context).enterTheirPaymentDetails
        : Loc.of(context).enterYourPaymentDetails;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
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
            _buildForm(context, selectedPayoutMethod),
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
                    payinCurrency: payinCurrency,
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
                      builder: (context) => SearchPayoutMethodsPage(
                        payoutCurrency: payinCurrency,
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

  Widget _buildForm(
    BuildContext context,
    ValueNotifier<PayoutMethod?> selectedPayoutMethod,
  ) =>
      selectedPayoutMethod.value == null
          ? _buildDisabledButton(context)
          : Expanded(
              child: JsonSchemaForm(
                schema: selectedPayoutMethod.value?.requiredPaymentDetails
                    ?.toJson(),
                onSubmit: (formData) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ReviewPaymentPage(
                        payinAmount: payinAmount,
                        payoutAmount: payoutAmount,
                        payinCurrency: payinCurrency,
                        payoutCurrency: payoutCurrency,
                        exchangeRate: exchangeRate,
                        serviceFee: selectedPayoutMethod.value?.fee ?? '0.00',
                        transactionType: transactionType,
                        paymentName: selectedPayoutMethod.value?.name ??
                            selectedPayoutMethod.value?.kind ??
                            '',
                        formData: formData,
                      ),
                    ),
                  );
                },
              ),
            );

  Widget _buildDisabledButton(BuildContext context) => Expanded(
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
