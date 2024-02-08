import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:flutter_starter/shared/grid.dart';
import 'package:flutter_starter/shared/json_schema_form.dart';
import 'package:flutter_starter/shared/payment_method.dart';
import 'package:flutter_starter/shared/search_payment_methods_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PaymentDetailsPage extends HookConsumerWidget {
  const PaymentDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentMethods = ref.watch(paymentMethodProvider);

    final paymentTypes =
        paymentMethods?.map((method) => method.kind.split('_').first).toSet();

    final selectedPaymentMethod = useState(paymentMethods?.firstOrNull);
    final selectedPaymentType = useState(paymentTypes?.firstOrNull);

    final availablePaymentMethods = paymentMethods
        ?.where(
          (method) => method.kind.contains(selectedPaymentType.value ?? ''),
        )
        .toList();

    useEffect(
      () {
        selectedPaymentMethod.value = availablePaymentMethods?.firstOrNull;
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
              availablePaymentMethods,
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
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).disabledColor,
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
    List<PaymentMethod>? availablePaymentMethods,
  ) {
    final paymentSubtype = selectedPaymentMethod.value?.kind.split('_').last;
    final fee = (double.tryParse(selectedPaymentMethod.value?.fee ?? '0.00')
            ?.toStringAsFixed(2) ??
        '0.00');

    return ListTile(
      title: Text(
        paymentSubtype ?? '',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
      subtitle: Text(
        Loc.of(context).serviceFeeAmount(fee, 'USD'),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: Grid.side),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SearchPaymentMethodsPage(
              selectedPaymentMethod: selectedPaymentMethod,
              paymentMethods: availablePaymentMethods,
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
        ? Container()
        : Expanded(
            child: JsonSchemaForm(
              schema: selectedPaymentMethod.value!.requiredPaymentDetails,
              onSubmit: (formData) {
                // TODO: save payment details here
              },
            ),
          );
  }
}
