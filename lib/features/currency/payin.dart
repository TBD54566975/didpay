import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/currency/currency.dart';
import 'package:didpay/features/currency/currency_dropdown.dart';
import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/shake_animated_text.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/utils/number_validation_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PayinKeyPress {
  final int count;
  final String key;

  PayinKeyPress(this.count, this.key);
}

class Payin extends HookWidget {
  final String transactionType;
  final ValueNotifier<String> amount;
  final ValueNotifier<PayinKeyPress> keyPress;
  final ValueNotifier<Currency?> currency;

  const Payin({
    required this.transactionType,
    required this.amount,
    required this.keyPress,
    required this.currency,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shouldAnimate = useState(false);

    final formattedAmount = transactionType == Type.deposit
        ? Currency.formatFromString(amount.value,
            currency: currency.value?.label)
        : Currency.formatFromString(amount.value);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) => amount.value = '0');
      return;
    }, [currency.value]);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final current = amount.value;
        final key = keyPress.value.key;
        if (key == '') return;

        shouldAnimate.value = (key == '<')
            ? !NumberValidationUtil.isValidDelete(current)
            : !NumberValidationUtil.isValidInput(
                current,
                key,
                currency: currency.value?.label,
              );
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShakeAnimatedWidget(
          shouldAnimate: shouldAnimate,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: AutoSizeText(
                      formattedAmount,
                      style: Theme.of(context).textTheme.displayMedium,
                      maxFontSize:
                          Theme.of(context).textTheme.displayMedium?.fontSize ??
                              45.0,
                      minFontSize:
                          Theme.of(context).textTheme.bodyLarge?.fontSize ??
                              16.0,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: Grid.half),
                  transactionType == Type.deposit
                      ? CurrencyDropdown(selectedCurrency: currency)
                      : Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: Grid.xxs),
                          child: Text(
                            Loc.of(context).usd,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: Grid.xs),
        Text(
          transactionType == Type.deposit
              ? Loc.of(context).youDeposit
              : Loc.of(context).youWithdraw,
          style: Theme.of(context).textTheme.bodyLarge,
        )
      ],
    );
  }
}
