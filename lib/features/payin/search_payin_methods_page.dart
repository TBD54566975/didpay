import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tbdex/tbdex.dart';

class SearchPayinMethodsPage extends HookWidget {
  final _formKey = GlobalKey<FormState>();

  final String payinCurrency;
  final ValueNotifier<PayinMethod?> selectedPayinMethod;
  final List<PayinMethod>? payinMethods;

  SearchPayinMethodsPage({
    required this.payinCurrency,
    required this.selectedPayinMethod,
    required this.payinMethods,
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
    ValueNotifier<PayinMethod?> selectedPayinMethod,
    ValueNotifier<String> searchText,
    List<PayinMethod>? payinMethods,
  ) {
    final filteredPaymentMethods = payinMethods
        ?.where(
          (entry) => (entry.name ?? entry.kind)
              .toLowerCase()
              .contains(searchText.value.toLowerCase()),
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
