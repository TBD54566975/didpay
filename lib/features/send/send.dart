import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/payin/payin.dart';
import 'package:didpay/shared/shake_animated_text.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/utils/currency_util.dart';
import 'package:didpay/shared/utils/number_validation_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Send extends HookWidget {
  final ValueNotifier<String> amount;
  final ValueNotifier<PayinKeyPress> keyPress;

  const Send({
    required this.amount,
    required this.keyPress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shouldAnimate = useState(false);
    final decimalPaddingHint = useState('');

    final formattedAmount = CurrencyUtil.formatFromString(amount.value);

    useEffect(
      () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final current = amount.value;
          final key = keyPress.value.key;
          if (key == '') return;

          shouldAnimate.value = (key == '<')
              ? !NumberValidationUtil.isValidDelete(current)
              : !NumberValidationUtil.isValidInput(current, key);
          if (shouldAnimate.value) return;

          if (key == '<') {
            amount.value = (current.length > 1)
                ? current.substring(0, current.length - 1)
                : '0';
          } else {
            amount.value = (current == '0' && key == '.')
                ? '$current$key'
                : (current == '0')
                    ? key
                    : '$current$key';
          }

          final decimalDigits = CurrencyUtil.getDecimalDigits('USDC');
          final hasDecimal = amount.value.contains('.');
          final hintDigits = hasDecimal
              ? decimalDigits - amount.value.split('.')[1].length
              : decimalDigits;

          decimalPaddingHint.value = hasDecimal && hintDigits > 0
              ? (hintDigits == decimalDigits ? '.' : '') + '0' * hintDigits
              : '';
        });

        return;
      },
      [keyPress.value],
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ShakeAnimatedWidget(
          shouldAnimate: shouldAnimate,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Grid.side),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: AutoSizeText.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: formattedAmount),
                            TextSpan(
                              text: decimalPaddingHint.value,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: Grid.half),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Grid.xxs),
                      child: Text(
                        'USDC',
                        style:
                            Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
