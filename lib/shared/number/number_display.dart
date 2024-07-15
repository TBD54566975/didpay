import 'package:auto_size_text/auto_size_text.dart';
import 'package:decimal/decimal.dart';
import 'package:didpay/features/payment/payment_amount_state.dart';
import 'package:didpay/shared/currency_formatter.dart';
import 'package:didpay/shared/number/number_key_press.dart';
import 'package:didpay/shared/shake_animated_text.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/utils/number_validation_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class NumberDisplay extends HookWidget {
  final Widget currencyWidget;
  final ValueNotifier<PaymentAmountState?> state;
  final ValueNotifier<NumberKeyPress> keyPress;
  final TextStyle? textStyle;

  const NumberDisplay({
    required this.currencyWidget,
    required this.state,
    required this.keyPress,
    this.textStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shouldAnimate = useState(false);
    final decimalHint = useState('');

    final formattedAmount = Decimal.parse(state.value?.payinAmount ?? '0')
        .formatCurrency(state.value?.payinCurrency ?? '');
    final displayAmount = _denormalizeAmount(formattedAmount);

    useEffect(
      () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final key = keyPress.value.key;
          if (key == '') return;

          _handleKeyPress(
            shouldAnimate,
            key,
            state.value?.payinAmount ?? '0',
            state.value?.payinCurrency ?? '',
          );
          _updateDecimalHint(
            state.value?.payinAmount ?? '0',
            state.value?.payinCurrency ?? '',
            decimalHint,
          );
        });

        return;
      },
      [keyPress.value],
    );

    return ShakeAnimatedWidget(
      shouldAnimate: shouldAnimate,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: textStyle != null
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: AutoSizeText.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: displayAmount),
                      TextSpan(
                        text: decimalHint.value,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  style: textStyle ?? Theme.of(context).textTheme.displayMedium,
                ),
              ),
              const SizedBox(width: Grid.half),
              currencyWidget,
            ],
          ),
        ],
      ),
    );
  }

  void _handleKeyPress(
    ValueNotifier<bool> shouldAnimate,
    String key,
    String current,
    String currencyCode,
  ) {
    shouldAnimate.value = (key == '<')
        ? NumberValidationUtil.isInvalidDelete(current)
        : NumberValidationUtil.isInvalidInput(
            current,
            key,
            currency: currencyCode,
          );
    if (shouldAnimate.value) return;

    if (key == '<') {
      state.value = state.value?.copyWith(
        payinAmount: (current.length > 1)
            ? current.substring(0, current.length - 1)
            : '0',
      );
    } else {
      state.value = state.value?.copyWith(
        payinAmount: (current == '0' && key == '.')
            ? '$current$key'
            : (current == '0')
                ? key
                : '$current$key',
      );
    }
  }

  void _updateDecimalHint(
    String amount,
    String currency,
    ValueNotifier<String> decimalHint,
  ) {
    final decimalDigits = currency == 'BTC' ? 8 : 2;
    final hintDigits = decimalDigits - _getDecimalScale(amount);

    decimalHint.value =
        _isDecimal(amount) && hintDigits > 0 ? '0' * hintDigits : '';
  }

  /// Adds trailing zeros to a formatted decimal amount if they were trimmed.
  ///
  /// This function takes a [formattedAmount] string, removes any commas, and
  /// compares it to the current [state]. If [state] has more decimal places,
  /// it appends the necessary trailing zeros to [formattedAmount] to match the
  /// expected scale.
  String _denormalizeAmount(String formattedAmount) {
    final unformattedAmount = formattedAmount.replaceAll(',', '');
    if (state.value?.payinAmount == null ||
        state.value?.payinAmount == unformattedAmount) {
      return formattedAmount;
    }

    final missingZeros = '0' *
        (_getDecimalScale(state.value?.payinAmount ?? '') -
            _getDecimalScale(formattedAmount));

    return Decimal.parse(state.value?.payinAmount ?? '0').isInteger
        ? '$formattedAmount.$missingZeros'
        : '$formattedAmount$missingZeros';
  }

  int _getDecimalScale(String amount) =>
      _isDecimal(amount) ? amount.split('.').last.length : 0;

  bool _isDecimal(String amount) => amount.contains('.');
}
