import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:didpay/features/payment/payment_method.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';

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
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(Loc.of(context).paymentMethods),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Grid.side),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: Grid.xs),
                    TextFormField(
                      focusNode: focusNode,
                      onTapOutside: (_) => focusNode.unfocus(),
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: Loc.of(context).search,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: Grid.side,
                        ),
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Grid.xs),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) => searchText.value = value,
                    ),
                  ],
                ),
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
            entry.name.toLowerCase().contains(searchText.value.toLowerCase()))
        .toList();

    return ListView.builder(
      itemBuilder: (context, index) {
        final currentPaymentMethod =
            filteredPaymentMethods?.elementAtOrNull(index);
        final fee = (double.tryParse(currentPaymentMethod?.fee ?? '0.00')
                ?.toStringAsFixed(2) ??
            '0.00');

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
