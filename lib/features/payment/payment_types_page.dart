import 'package:didpay/features/payment/payment_details_state.dart';
import 'package:didpay/shared/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PaymentTypesPage extends HookWidget {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<PaymentDetailsState> state;

  PaymentTypesPage({
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
              child: _buildTypesList(
                context,
                searchText,
                state,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypesList(
    BuildContext context,
    ValueNotifier<String> searchText,
    ValueNotifier<PaymentDetailsState> state,
  ) {
    final filteredPaymentTypes = state.value.paymentTypes
        ?.where(
          (entry) =>
              entry.toLowerCase().contains(searchText.value.toLowerCase()),
        )
        .toList();

    return ListView.builder(
      itemBuilder: (context, index) {
        final currentPaymentType = filteredPaymentTypes?.elementAtOrNull(index);
        final selected = state.value.selectedPaymentType == currentPaymentType;

        return ListTile(
          visualDensity: VisualDensity.compact,
          selected: selected,
          title: Text(currentPaymentType ?? ''),
          trailing: selected ? const Icon(Icons.check) : null,
          onTap: () {
            if (currentPaymentType != null) {
              state.value =
                  state.value.copyWith(selectedPaymentType: currentPaymentType);
            }

            Navigator.of(context).pop();
          },
        );
      },
      itemCount: filteredPaymentTypes?.length,
    );
  }
}
