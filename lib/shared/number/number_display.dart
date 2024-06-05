import 'package:auto_size_text/auto_size_text.dart';
import 'package:decimal/decimal.dart';
import 'package:didpay/shared/currency_formatter.dart';
import 'package:didpay/shared/number/number_key_press.dart';
import 'package:didpay/shared/shake_animated_text.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/utils/number_validation_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class NumberDisplay extends HookWidget {
  final String currencyCode;
  final Widget currencyWidget;
  final ValueNotifier<String> amount;
  final ValueNotifier<NumberKeyPress> keyPress;
  final TextStyle? textStyle;

  const NumberDisplay({
    required this.currencyCode,
    required this.currencyWidget,
    required this.amount,
    required this.keyPress,
    this.textStyle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shouldAnimate = useState(false);
    final decimalHint = useState('');

    final formattedAmount =
        Decimal.parse(amount.value).formatCurrency(currencyCode);
    final displayAmount = _denormalizeAmount(formattedAmount);

    useEffect(
      () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final key = keyPress.value.key;
          if (key == '') return;

          _handleKeyPress(shouldAnimate, amount.value, key, currencyCode);
          _updateDecimalHint(decimalHint, currencyCode);
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
    String current,
    String key,
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
      amount.value =
          (current.length > 1) ? current.substring(0, current.length - 1) : '0';
    } else {
      amount.value = (current == '0' && key == '.')
          ? '$current$key'
          : (current == '0')
              ? key
              : '$current$key';
    }
  }

  void _updateDecimalHint(
    ValueNotifier<String> decimalHint,
    String currencyCode,
  ) {
    final decimalDigits = currencyCode == 'BTC' ? 8 : 2;
    final hintDigits = decimalDigits - _getDecimalScale(amount.value);

    decimalHint.value =
        _isDecimal(amount.value) && hintDigits > 0 ? '0' * hintDigits : '';
  }

  /// Adds trailing zeros to a formatted decimal amount if they were trimmed.
  ///
  /// This function takes a [formattedAmount] string, removes any commas, and
  /// compares it to the current [amount]. If [amount] has more decimal places,
  /// it appends the necessary trailing zeros to [formattedAmount] to match the
  /// expected scale.
  String _denormalizeAmount(String formattedAmount) {
    final unformattedAmount = formattedAmount.replaceAll(',', '');
    if (amount.value == unformattedAmount) {
      return formattedAmount;
    }

    final expectedScale = amount.value.split('.').last.length;
    final actualScale = formattedAmount.contains('.')
        ? formattedAmount.split('.').last.length
        : 0;
    final missingZeros = '0' * (expectedScale - actualScale);

    final isWholeNum =
        Decimal.parse(amount.value).toString() == unformattedAmount;

    return isWholeNum
        ? '$formattedAmount.$missingZeros'
        : '$formattedAmount$missingZeros';
  }

  int _getDecimalScale(String amount) =>
      _isDecimal(amount) ? amount.split('.').last.length : 0;

  bool _isDecimal(String amount) => amount.contains('.');
}
