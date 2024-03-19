import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';

class SearchPaymentTypesPage extends HookWidget {
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<String?> selectedPaymentType;
  final Set<String?>? paymentTypes;
  final String payinCurrency;

  SearchPaymentTypesPage({
    required this.selectedPaymentType,
    required this.paymentTypes,
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

  Widget _buildList(
    BuildContext context,
    ValueNotifier<String?> selectedPaymentMethod,
    ValueNotifier<String> searchText,
    Set<String?>? paymentTypes,
  ) {
    final filteredPaymentTypes = paymentTypes
        ?.where((entry) =>
            entry?.toLowerCase().contains(searchText.value.toLowerCase()) ??
            false)
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
