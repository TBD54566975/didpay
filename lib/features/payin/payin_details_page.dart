import 'package:collection/collection.dart';
import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/features/payin/search_payin_methods_page.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/payment/review_payment_page.dart';
import 'package:didpay/features/payment/search_payment_types_page.dart';
import 'package:didpay/features/tbdex/rfq_state.dart';
import 'package:didpay/features/tbdex/tbdex_providers.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/json_schema_form.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

class PayinDetailsPage extends HookConsumerWidget {
  final RfqState rfqState;
  final PaymentState paymentState;

  const PayinDetailsPage({
    required this.rfqState,
    required this.paymentState,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payinTypes = paymentState.payinMethods
        ?.map((method) => method.group)
        .whereType<String>()
        .toSet();

    final selectedPayinType = useState<String?>(null);
    final selectedPayinMethod = useState<PayinMethod?>(null);

    final filteredPayinMethods = paymentState.payinMethods
        ?.where(
          (method) =>
              method.group?.contains(selectedPayinType.value ?? '') ?? true,
        )
        .toList();

    useEffect(
      () {
        selectedPayinMethod.value = (filteredPayinMethods?.length ?? 1) <= 1
            ? selectedPayinMethod.value = filteredPayinMethods?.firstOrNull
            : null;
        return;
      },
      [selectedPayinType.value],
    );

    final shouldShowPayinTypeSelector = (payinTypes?.length ?? 0) > 1;
    final shouldShowPayinMethodSelector =
        !shouldShowPayinTypeSelector || selectedPayinType.value != null;

    final headerTitle = paymentState.transactionType == TransactionType.send
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
            if (shouldShowPayinTypeSelector)
              _buildPayinTypeSelector(
                context,
                selectedPayinType,
                payinTypes,
              ),
            if (shouldShowPayinMethodSelector)
              _buildPayinMethodSelector(
                context,
                selectedPayinMethod,
                filteredPayinMethods,
              ),
            _buildForm(context, ref, selectedPayinMethod.value),
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

  Widget _buildPayinTypeSelector(
    BuildContext context,
    ValueNotifier<String?> selectedPayinType,
    Set<String?>? payinTypes,
  ) =>
      Column(
        children: [
          const SizedBox(height: Grid.xxs),
          ListTile(
            title: Text(
              selectedPayinType.value == null
                  ? Loc.of(context).selectPaymentType
                  : selectedPayinType.value ?? '',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SearchPaymentTypesPage(
                    selectedPaymentType: selectedPayinType,
                    paymentTypes: payinTypes,
                    payinCurrency: paymentState.payinCurrency,
                  ),
                ),
              );
            },
          ),
        ],
      );

  Widget _buildPayinMethodSelector(
    BuildContext context,
    ValueNotifier<PayinMethod?> selectedPayinMethod,
    List<PayinMethod>? filteredPayinMethods,
  ) {
    final isSelectionDisabled = (filteredPayinMethods?.length ?? 0) <= 1;
    final fee = double.tryParse(selectedPayinMethod.value?.fee ?? '0.00')
            ?.toStringAsFixed(2) ??
        '0.00';

    if (isSelectionDisabled) {
      selectedPayinMethod.value = filteredPayinMethods?.firstOrNull;
    }

    return Column(
      children: [
        const SizedBox(height: Grid.xxs),
        ListTile(
          title: Text(
            selectedPayinMethod.value == null
                ? Loc.of(context).selectPaymentMethod
                : selectedPayinMethod.value?.name ??
                    selectedPayinMethod.value?.kind ??
                    '',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          subtitle: Text(
            selectedPayinMethod.value?.name == null
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
                      builder: (context) => SearchPayinMethodsPage(
                        payinCurrency: paymentState.payinCurrency,
                        selectedPayinMethod: selectedPayinMethod,
                        payinMethods: filteredPayinMethods,
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
    WidgetRef ref,
    PayinMethod? selectedPayinMethod,
  ) =>
      selectedPayinMethod == null
          ? _buildDisabledButton(context)
          : Expanded(
              child: JsonSchemaForm(
                schema: selectedPayinMethod.requiredPaymentDetails?.toJson(),
                onSubmit: (formData) {
                  // TODO(ethan-tbd): wait for quote to come back before navigating, https://github.com/TBD54566975/didpay/issues/131
                  ref.read(
                    rfqProvider(
                      rfqState.copyWith(payinMethod: selectedPayinMethod),
                    ),
                  );

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ReviewPaymentPage(
                        rfqState: rfqState,
                        paymentState: paymentState.copyWith(
                          serviceFee: selectedPayinMethod.fee,
                          paymentName: selectedPayinMethod.name ??
                              selectedPayinMethod.kind,
                          formData: formData,
                        ),
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
