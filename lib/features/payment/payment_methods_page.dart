import 'package:didpay/features/payment/payment_details_state.dart';
import 'package:didpay/features/payment/payment_method.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PaymentMethodsPage extends HookWidget {
  final _formKey = GlobalKey<FormState>();

  final List<PaymentMethod>? availableMethods;
  final ValueNotifier<PaymentDetailsState> state;

  PaymentMethodsPage({
    required this.availableMethods,
    required this.state,
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
                availableMethods,
                state,
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
    List<PaymentMethod>? availableMethods,
    ValueNotifier<PaymentDetailsState> state,
  ) {
    final filteredPaymentMethods = availableMethods
        ?.where(
          (method) => method.title
              .toLowerCase()
              .contains(searchText.value.toLowerCase()),
        )
        .toList();

    return ListView.builder(
      itemBuilder: (context, index) {
        final currentPaymentMethod =
            filteredPaymentMethods?.elementAtOrNull(index);
        final selected =
            state.value.selectedPaymentMethod == currentPaymentMethod;

        final fee = double.tryParse(currentPaymentMethod?.fee ?? '0.00')
                ?.toStringAsFixed(2) ??
            '0.00';

        return ListTile(
          visualDensity: VisualDensity.compact,
          selected: selected,
          title: Text(currentPaymentMethod?.title ?? ''),
          subtitle: Text(
            Loc.of(context)
                .serviceFeeAmount(fee, state.value.paymentCurrency ?? ''),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: selected ? const Icon(Icons.check) : null,
          onTap: () {
            if (currentPaymentMethod != null) {
              state.value = state.value.copyWith(
                selectedPaymentMethod: currentPaymentMethod,
                paymentName: currentPaymentMethod.title,
              );
            }

            Navigator.of(context).pop();
          },
        );
      },
      itemCount: filteredPaymentMethods?.length,
    );
  }
}
