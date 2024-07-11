import 'package:didpay/features/currency/currency_dropdown.dart';
import 'package:didpay/features/payment/payment_amount_state.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/number/number_display.dart';
import 'package:didpay/shared/number/number_key_press.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Payin extends HookWidget {
  final TransactionType transactionType;
  final ValueNotifier<PaymentAmountState?> state;
  final ValueNotifier<NumberKeyPress> keyPress;

  const Payin({
    required this.transactionType,
    required this.state,
    required this.keyPress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    useEffect(
      () {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => state.value = state.value?.copyWith(payinAmount: '0'),
        );
        return;
      },
      [state.value?.selectedOffering],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NumberDisplay(
          currencyWidget: _buildPayinCurrency(context),
          state: state,
          keyPress: keyPress,
        ),
        const SizedBox(height: Grid.xs),
        _buildPayinLabel(context),
      ],
    );
  }

  Widget _buildPayinCurrency(BuildContext context) {
    switch (transactionType) {
      case TransactionType.deposit:
      case TransactionType.send:
        return CurrencyDropdown(
          paymentCurrency: state.value?.payinCurrency ?? '',
          state: state,
        );
      case TransactionType.withdraw:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Grid.xxs),
          child: Text(
            state.value?.payinCurrency ?? '',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        );
    }
  }

  Widget _buildPayinLabel(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge;
    final labels = {
      TransactionType.deposit: Loc.of(context).youPay,
      TransactionType.withdraw: Loc.of(context).youWithdraw,
      TransactionType.send: Loc.of(context).youSend,
    };

    final label = labels[transactionType] ?? 'unknown transaction type';

    return Text(label, style: style);
  }
}
