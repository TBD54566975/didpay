import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_starter/shared/grid.dart';
import 'package:flutter_starter/shared/payment_method.dart';

class PaymentMethodsPage extends HookWidget {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<PaymentMethod> selectedPaymentMethod;
  final List<PaymentMethod> paymentMethods;

  PaymentMethodsPage({
    required this.selectedPaymentMethod,
    required this.paymentMethods,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final searchText = useState<String>('');

    return Scaffold(
      appBar: AppBar(scrolledUnderElevation: 0),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Grid.sm),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Search',
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (value) => searchText.value = value,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildList(
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

  Widget _buildList(
    BuildContext context,
    ValueNotifier<PaymentMethod> selectedPaymentMethod,
    ValueNotifier<String> searchText,
    List<PaymentMethod> paymentMethods,
  ) {
    final filteredPaymentMethods = paymentMethods
        .where((entry) =>
            entry.kind.toLowerCase().contains(searchText.value.toLowerCase()))
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Grid.sm),
      child: ListView.builder(
        itemBuilder: (context, index) {
          final currentPaymentMethod = filteredPaymentMethods.elementAt(index);

          final paymentProvider = currentPaymentMethod.kind.split('_').last;

          return ListTile(
            visualDensity: VisualDensity.compact,
            selected: selectedPaymentMethod.value == currentPaymentMethod,
            title: Text(paymentProvider),
            subtitle: Text(
              'Service fee',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: selectedPaymentMethod.value == currentPaymentMethod
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              selectedPaymentMethod.value = currentPaymentMethod;
              print('Selected payment method: ${currentPaymentMethod.kind}');
              Navigator.of(context).pop();
            },
          );
        },
        itemCount: filteredPaymentMethods.length,
      ),
    );
  }
}
