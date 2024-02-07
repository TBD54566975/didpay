import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:flutter_starter/shared/grid.dart';
import 'package:flutter_starter/shared/json_schema_form.dart';
import 'package:flutter_starter/shared/payment_method.dart';
import 'package:flutter_starter/shared/payment_methods_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PaymentDetailsPage extends HookConsumerWidget {
  const PaymentDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentMethods = ref.watch(paymentMethodProvider);

    final selectedPaymentMethod = useState<PaymentMethod>(paymentMethods.first);
    final selectedPaymentType =
        useState<String>(paymentMethods.first.kind.split('_').first);

    final paymentTypes =
        paymentMethods.map((method) => method.kind.split('_').first).toSet();

    final Map<String, List<PaymentMethod>> typeToPaymentMethods = {};

    for (var method in paymentMethods) {
      var prefix = method.kind.split('_').first;
      (typeToPaymentMethods.putIfAbsent(prefix, () => [])..add(method));
    }

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (paymentTypes.length > 1)
              _buildPaymentTypeSegments(
                context,
                paymentTypes,
                selectedPaymentType,
                selectedPaymentMethod,
                typeToPaymentMethods,
              ),
            _buildHeader(
              context,
              Loc.of(context).enterYourPaymentChannelDetails(
                selectedPaymentType.value.toLowerCase(),
              ),
            ),
            const SizedBox(
              height: Grid.xs,
            ),
            _buildPaymentProvider(
              context,
              selectedPaymentMethod,
              typeToPaymentMethods[selectedPaymentType.value] ?? [],
            ),
            Expanded(
              child: JsonSchemaForm(
                  schema: selectedPaymentMethod.value.requiredPaymentDetails,
                  onSubmit: (formData) {
                    print('Form data submitted: $formData');
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentProvider(
    BuildContext context,
    ValueNotifier<PaymentMethod> selectedPaymentMethod,
    List<PaymentMethod> paymentMethods,
  ) {
    return ListTile(
      title: Text(
        selectedPaymentMethod.value.kind,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
      subtitle: Text(
        'Service fee',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: Grid.side),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentMethodsPage(
              selectedPaymentMethod: selectedPaymentMethod,
              paymentMethods: paymentMethods,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentTypeSegments(
    BuildContext context,
    Set<String> paymentTypes,
    ValueNotifier<String> selectedPaymentType,
    ValueNotifier<PaymentMethod> selectedPaymentMethod,
    Map<String, List<PaymentMethod>> typeToPaymentMethods,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        left: Grid.side,
        right: Grid.side,
      ),
      child: SegmentedButton<String>(
        segments: paymentTypes
            .map(
              (segment) => ButtonSegment<String>(
                value: segment,
                label: Text(
                  segment,
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
        onSelectionChanged: (value) {
          selectedPaymentType.value = value.first;
          selectedPaymentMethod.value =
              typeToPaymentMethods[value.first]!.first;
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              return states.contains(MaterialState.selected)
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context).colorScheme.secondaryContainer;
            },
          ),
          side: MaterialStateProperty.resolveWith<BorderSide>(
            (Set<MaterialState> _) {
              return BorderSide(
                color: Theme.of(context).colorScheme.secondaryContainer,
                width: 3.0,
              );
            },
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
          ),
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
}
