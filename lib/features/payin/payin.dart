import 'package:auto_size_text/auto_size_text.dart';
import 'package:decimal/decimal.dart';
import 'package:didpay/features/currency/currency_dropdown.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/currency_formatter.dart';
import 'package:didpay/shared/shake_animated_text.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/utils/number_validation_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tbdex/tbdex.dart';

class Payin extends HookWidget {
  final PaymentState paymentState;
  final ValueNotifier<String> payinAmount;
  final ValueNotifier<PayinKeyPress> keyPress;
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
    final shouldAnimate = useState(false);
    final hintDigits = useState(0);
    final decimalPaddingHint = useState('');

    final currencyCode =
        paymentState.selectedOffering?.data.payin.currencyCode ?? '';
    final formattedAmount = Decimal.parse(payinAmount.value).formatCurrency(
      currencyCode,
      hintDigits: hintDigits.value,
    );

    useEffect(
      () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          payinAmount.value = '0';
          decimalPaddingHint.value = '';
          hintDigits.value = 0;
        });
        return;
      },
      [paymentState.selectedOffering],
    );

    useEffect(
      () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final current = payinAmount.value;
          final key = keyPress.value.key;
          if (key == '') return;

          shouldAnimate.value = (key == '<')
              ? !NumberValidationUtil.isValidDelete(current)
              : (paymentState.transactionType == TransactionType.deposit
                  ? !NumberValidationUtil.isValidInput(
                      current,
                      key,
                      currency: paymentState
                          .selectedOffering?.data.payin.currencyCode,
                    )
                  : !NumberValidationUtil.isValidInput(current, key));
          if (shouldAnimate.value) return;

          if (key == '<') {
            payinAmount.value = (current.length > 1)
                ? current.substring(0, current.length - 1)
                : '0';
          } else {
            payinAmount.value = (current == '0' && key == '.')
                ? '$current$key'
                : (current == '0')
                    ? key
                    : '$current$key';
          }

          final decimalDigits =
              paymentState.selectedOffering?.data.payin.currencyCode == 'BTC'
                  ? 8
                  : 2;

          final hasDecimal = payinAmount.value.contains('.');
          hintDigits.value = hasDecimal
              ? decimalDigits - payinAmount.value.split('.')[1].length
              : decimalDigits;

          decimalPaddingHint.value =
              hasDecimal && hintDigits.value > 0 ? '0' * hintDigits.value : '';
        });

        return;
      },
      [keyPress.value],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShakeAnimatedWidget(
          shouldAnimate: shouldAnimate,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: AutoSizeText.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: denormalizeDecimal(formattedAmount)),
                          TextSpan(
                            text: decimalPaddingHint.value,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ),
                  const SizedBox(width: Grid.half),
                  _buildPayinCurrency(context),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: Grid.xs),
        _buildPayinLabel(context),
      ],
    );
  }

  Widget _buildPayinCurrency(BuildContext context) {
    switch (paymentState.transactionType) {
      case TransactionType.deposit:
        return CurrencyDropdown(
          paymentState: paymentState,
          onCurrencySelect: onCurrencySelect,
        );
      case TransactionType.withdraw:
      case TransactionType.send:
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

  String denormalizeDecimal(String amount) {
    if (!payinAmount.value.contains('.') || payinAmount.value == amount) {
      return amount;
    }

    final amountWithDecimal = '$amount.';
    final missingZeros = payinAmount.value.split('.').last.length -
        amountWithDecimal.split('.').last.length;

    return '$amountWithDecimal${'0' * missingZeros}';
  }
}

class PayinKeyPress {
  final int count;
  final String key;

  PayinKeyPress(this.count, this.key);
}
