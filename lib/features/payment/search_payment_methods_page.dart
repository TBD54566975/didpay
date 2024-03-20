import 'package:didpay/features/payment/payment_method.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/search_field.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SearchPaymentMethodsPage extends HookWidget {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<PaymentMethod?> selectedPaymentMethod;
  final List<PaymentMethod>? paymentMethods;
  final String payinCurrency;

  SearchPaymentMethodsPage({
    required this.selectedPaymentMethod,
    required this.paymentMethods,
    required this.payinCurrency,
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
                selectedPaymentMethod,
                searchText,
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
    ValueNotifier<PaymentMethod?> selectedPaymentMethod,
    ValueNotifier<String> searchText,
    List<PaymentMethod>? paymentMethods,
  ) {
    final filteredPaymentMethods = paymentMethods
        ?.where(
          (entry) =>
              entry.name.toLowerCase().contains(searchText.value.toLowerCase()),
        )
        .toList();

    return ListView.builder(
      itemBuilder: (context, index) {
        final currentPaymentMethod =
            filteredPaymentMethods?.elementAtOrNull(index);
        final fee = double.tryParse(currentPaymentMethod?.fee ?? '0.00')
                ?.toStringAsFixed(2) ??
            '0.00';

        return ListTile(
          visualDensity: VisualDensity.compact,
          selected: selectedPaymentMethod.value == currentPaymentMethod,
          title: Text(currentPaymentMethod?.name ?? ''),
          subtitle: Text(
            Loc.of(context).serviceFeeAmount(fee, payinCurrency),
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
