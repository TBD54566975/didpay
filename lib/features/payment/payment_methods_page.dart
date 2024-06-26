import 'package:didpay/features/payment/payment_method_operations.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PaymentMethodsPage extends HookWidget {
  final _formKey = GlobalKey<FormState>();

  final String? paymentCurrency;
  final ValueNotifier<Object?> selectedPaymentMethod;
  final List<Object?>? paymentMethods;

  PaymentMethodsPage({
    required this.paymentCurrency,
    required this.selectedPaymentMethod,
    required this.paymentMethods,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final searchText = useState('');
    final focusNode = useFocusNode();

    return Scaffold(
      appBar: AppBar(scrolledUnderElevation: 0),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SearchField(
              focusNode: focusNode,
              formKey: _formKey,
              searchText: searchText,
            ),
            Expanded(
              child: _buildMethodsList(
                context,
                searchText,
                selectedPaymentMethod,
                paymentMethods,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodsList(
    BuildContext context,
    ValueNotifier<String> searchText,
    ValueNotifier<Object?> selectedPaymentMethod,
    List<Object?>? paymentMethods,
  ) {
    final filteredPaymentMethods = paymentMethods
        ?.where(
          (method) => (method.paymentName ?? '')
              .toLowerCase()
              .contains(searchText.value.toLowerCase()),
        )
        .toList();

    return ListView.builder(
      itemBuilder: (context, index) {
        final currentPaymentMethod =
            filteredPaymentMethods?.elementAtOrNull(index);
        final fee = double.tryParse(currentPaymentMethod.paymentFee ?? '0.00')
                ?.toStringAsFixed(2) ??
            '0.00';

        return ListTile(
          visualDensity: VisualDensity.compact,
          selected: selectedPaymentMethod.value == currentPaymentMethod,
          title: Text(
            currentPaymentMethod?.paymentName ?? '',
          ),
          subtitle: Text(
            Loc.of(context).serviceFeeAmount(fee, paymentCurrency ?? ''),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: selectedPaymentMethod.value == currentPaymentMethod
              ? const Icon(Icons.check)
              : null,
          onTap: () {
            selectedPaymentMethod.value =
                currentPaymentMethod ?? selectedPaymentMethod.value;
            Navigator.of(context).pop();
          },
        );
      },
      itemCount: filteredPaymentMethods?.length,
    );
  }
}
