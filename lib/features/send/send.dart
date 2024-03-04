import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/currency/currency.dart';
import 'package:didpay/features/currency/payin.dart';
import 'package:didpay/shared/shake_animated_text.dart';
import 'package:didpay/shared/theme/grid.dart';
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

    final formattedAmount =
        Currency.formatFromString(amount.value, showSymbol: true);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final key = keyPress.value.key;
        if (key == '') return;

        final current = amount.value;

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
      });

      return;
    }, [keyPress.value]);

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
                      child: AutoSizeText(
                        formattedAmount,
                        style: const TextStyle(
                          fontSize: 80.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxFontSize: 80.0,
                        minFontSize:
                            Theme.of(context).textTheme.bodyLarge?.fontSize ??
                                16.0,
                        maxLines: 1,
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
