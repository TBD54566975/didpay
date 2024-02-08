import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:flutter_starter/shared/grid.dart';
import 'package:flutter_starter/shared/payment_method.dart';

class SearchPaymentMethodsPage extends HookWidget {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<PaymentMethod?> selectedPaymentMethod;
  final List<PaymentMethod>? paymentMethods;

  SearchPaymentMethodsPage({
    required this.selectedPaymentMethod,
    required this.paymentMethods,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final searchText = useState('');

    return Scaffold(
      appBar: AppBar(scrolledUnderElevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Grid.side),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: Loc.of(context).search,
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (value) => searchText.value = value,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Grid.xs),
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
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    ValueNotifier<PaymentMethod?> selectedPaymentMethod,
    ValueNotifier<String> searchText,
    List<PaymentMethod>? paymentMethods,
  ) {
    final filteredPaymentMethods = paymentMethods
        ?.where((entry) =>
            entry.kind.toLowerCase().contains(searchText.value.toLowerCase()))
        .toList();

    return ListView.builder(
      itemBuilder: (context, index) {
        final currentPaymentMethod =
            filteredPaymentMethods?.elementAtOrNull(index);
        final paymentSubtype = currentPaymentMethod?.kind.split('_').last;
        final fee = (double.tryParse(currentPaymentMethod?.fee ?? '0.00')
                ?.toStringAsFixed(2) ??
            '0.00');

        return ListTile(
          visualDensity: VisualDensity.compact,
          selected: selectedPaymentMethod.value == currentPaymentMethod,
          title: Text(paymentSubtype ?? ''),
          subtitle: Text(
            Loc.of(context).serviceFeeAmount(fee, 'USD'),
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
