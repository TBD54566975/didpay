import 'package:didpay/shared/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PaymentTypesPage extends HookWidget {
  final _formKey = GlobalKey<FormState>();
  final String? payinCurrency;
  final Set<String?>? paymentTypes;
  final ValueNotifier<String?> selectedPaymentType;

  PaymentTypesPage({
    required this.payinCurrency,
    required this.paymentTypes,
    required this.selectedPaymentType,
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
              child: _buildTypesList(
                context,
                selectedPaymentType,
                searchText,
                paymentTypes,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypesList(
    BuildContext context,
    ValueNotifier<String?> selectedPaymentMethod,
    ValueNotifier<String> searchText,
    Set<String?>? paymentTypes,
  ) {
    final filteredPaymentTypes = paymentTypes
        ?.where(
          (entry) =>
              entry?.toLowerCase().contains(searchText.value.toLowerCase()) ??
              false,
        )
        .toList();

    return ListView.builder(
      itemBuilder: (context, index) {
        final currentPaymentType = filteredPaymentTypes?.elementAtOrNull(index);

        return ListTile(
          visualDensity: VisualDensity.compact,
          selected: selectedPaymentMethod.value == currentPaymentType,
          title: Text(currentPaymentType ?? ''),
          trailing: selectedPaymentMethod.value == currentPaymentType
              ? const Icon(Icons.check)
              : null,
          onTap: () {
            selectedPaymentMethod.value =
                currentPaymentType ?? selectedPaymentMethod.value;
            Navigator.of(context).pop();
          },
        );
      },
      itemCount: filteredPaymentTypes?.length,
    );
  }
}
