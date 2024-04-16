import 'package:didpay/features/payment/payment_method.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// TODO(ethan-tbd): replace PaymentMethod with PayinMethod when tbdex is in
class SearchPayinMethodsPage extends HookWidget {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<PaymentMethod?> selectedPayinMethod;
  final List<PaymentMethod>? payinMethods;
  final String payinCurrency;

  SearchPayinMethodsPage({
    required this.selectedPayinMethod,
    required this.payinMethods,
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
                selectedPayinMethod,
                searchText,
                payinMethods,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodsList(
    BuildContext context,
    ValueNotifier<PaymentMethod?> selectedPayinMethod,
    ValueNotifier<String> searchText,
    List<PaymentMethod>? payinMethods,
  ) {
    final filteredPaymentMethods = payinMethods
        ?.where(
          // TODO(ethan-tbd): use entry.kind if name is null when tbdex is in
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
          selected: selectedPayinMethod.value == currentPaymentMethod,
          title: Text(
            currentPaymentMethod?.name ?? currentPaymentMethod?.kind ?? '',
          ),
          subtitle: Text(
            Loc.of(context).serviceFeeAmount(fee, payinCurrency),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: selectedPayinMethod.value == currentPaymentMethod
              ? const Icon(Icons.check)
              : null,
          onTap: () {
            selectedPayinMethod.value =
                currentPaymentMethod ?? selectedPayinMethod.value;
            Navigator.of(context).pop();
          },
        );
      },
      itemCount: filteredPaymentMethods?.length,
    );
  }
}
