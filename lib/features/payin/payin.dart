import 'package:didpay/features/currency/currency_dropdown.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/number/number_display.dart';
import 'package:didpay/shared/number/number_key_press.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tbdex/tbdex.dart';

class Payin extends HookWidget {
  final PaymentState paymentState;
  final ValueNotifier<String> payinAmount;
  final ValueNotifier<NumberKeyPress> keyPress;
  final void Function(Pfi, Offering) onCurrencySelect;

  const Payin({
    required this.paymentState,
    required this.payinAmount,
    required this.keyPress,
    required this.onCurrencySelect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    useEffect(
      () {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => payinAmount.value = '0');
        return;
      },
      [paymentState.selectedOffering],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NumberDisplay(
          currencyCode:
              paymentState.selectedOffering?.data.payin.currencyCode ?? '',
          currencyWidget: _buildPayinCurrency(context),
          amount: payinAmount,
          keyPress: keyPress,
        ),
        const SizedBox(height: Grid.xs),
        _buildPayinLabel(context),
      ],
    );
  }

  Widget _buildPayinCurrency(BuildContext context) {
    switch (paymentState.transactionType) {
      case TransactionType.deposit:
      case TransactionType.send:
        return CurrencyDropdown(
          paymentState: paymentState,
          onCurrencySelect: onCurrencySelect,
        );
      case TransactionType.withdraw:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Grid.xxs),
          child: Text(
            paymentState.selectedOffering?.data.payin.currencyCode ?? '',
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

    final label =
        labels[paymentState.transactionType] ?? 'unknown transaction type';

    return Text(label, style: style);
  }
}
