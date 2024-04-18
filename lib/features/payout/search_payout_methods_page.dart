import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tbdex/tbdex.dart';

class SearchPayoutMethodsPage extends HookWidget {
  final _formKey = GlobalKey<FormState>();

  final String payoutCurrency;
  final ValueNotifier<PayoutMethod?> selectedPayoutMethod;
  final List<PayoutMethod>? payoutMethods;

  SearchPayoutMethodsPage({
    required this.payoutCurrency,
    required this.selectedPayoutMethod,
    required this.payoutMethods,
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
                selectedPayoutMethod,
                searchText,
                payoutMethods,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodsList(
    BuildContext context,
    ValueNotifier<PayoutMethod?> selectedPayoutMethod,
    ValueNotifier<String> searchText,
    List<PayoutMethod>? payoutMethods,
  ) {
    final filteredPayoutMethods = payoutMethods
        ?.where(
          (entry) => (entry.name ?? entry.kind)
              .toLowerCase()
              .contains(searchText.value.toLowerCase()),
        )
        .toList();

    return ListView.builder(
      itemBuilder: (context, index) {
        final currentPayoutMethod =
            filteredPayoutMethods?.elementAtOrNull(index);
        final fee = double.tryParse(currentPayoutMethod?.fee ?? '0.00')
                ?.toStringAsFixed(2) ??
            '0.00';

        return ListTile(
          visualDensity: VisualDensity.compact,
          selected: selectedPayoutMethod.value == currentPayoutMethod,
          title: Text(
            currentPayoutMethod?.name ?? currentPayoutMethod?.kind ?? '',
          ),
          subtitle: Text(
            Loc.of(context).serviceFeeAmount(fee, payoutCurrency),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: selectedPayoutMethod.value == currentPayoutMethod
              ? const Icon(Icons.check)
              : null,
          onTap: () {
            selectedPayoutMethod.value =
                currentPayoutMethod ?? selectedPayoutMethod.value;
            Navigator.of(context).pop();
          },
        );
      },
      itemCount: filteredPayoutMethods?.length,
    );
  }
}
