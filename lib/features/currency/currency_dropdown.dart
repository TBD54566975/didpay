import 'package:didpay/features/currency/currency.dart';
import 'package:didpay/features/currency/currency_modal.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CurrencyDropdown extends HookConsumerWidget {
  final ValueNotifier<Currency?> selectedCurrency;

  const CurrencyDropdown({
    required this.selectedCurrency,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencies = ref.watch(currencyProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.keyboard_arrow_down),
        label: Text(
          selectedCurrency.value?.code.toString() ?? '',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.only(left: Grid.xxs),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        onPressed: () {
          CurrencyModal.show(
              context,
              (value) => selectedCurrency.value =
                  currencies.firstWhere((c) => c.code.toString() == value),
              currencies,
              selectedCurrency.value?.code.toString() ?? '');
        },
      ),
    );
  }
}
