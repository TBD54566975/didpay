import 'package:didpay/features/payment/payment_amount_state.dart';
import 'package:didpay/shared/modal/modal_select_currency.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CurrencyDropdown extends HookConsumerWidget {
  final String paymentCurrency;
  final ValueNotifier<PaymentAmountState?> state;

  const CurrencyDropdown({
    required this.paymentCurrency,
    required this.state,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => Directionality(
        textDirection: TextDirection.rtl,
        child: ElevatedButton.icon(
          key: const Key('currencyDropdownButton'),
          icon: const Icon(Icons.keyboard_arrow_down),
          label: _buildCurrencyLabel(context),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.only(left: Grid.xxs),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          onPressed: () => ModalSelectCurrency.show(
            context,
            state,
          ),
        ),
      );

  Widget _buildCurrencyLabel(BuildContext context) =>
      Text(paymentCurrency, style: Theme.of(context).textTheme.headlineMedium);
}
