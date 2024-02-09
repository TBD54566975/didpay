import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/animations/invalid_number_pad_input_animation.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:intl/intl.dart';

class CurrencyConverter extends HookWidget {
  final double inputAmount;
  final String inputLabel;
  final double outputAmount;
  final bool isValidKeyPress;
  final String? inputSelectedCurrency;
  final String? outputSelectedCurrency;
  final VoidCallback? onDropdownTap;

  const CurrencyConverter({
    required this.inputAmount,
    required this.inputLabel,
    required this.outputAmount,
    required this.isValidKeyPress,
    this.inputSelectedCurrency,
    this.outputSelectedCurrency,
    this.onDropdownTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow(
            context,
            InvalidNumberPadInputAnimation(
                textValue: NumberFormat.simpleCurrency().format(inputAmount),
                textStyle: Theme.of(context).textTheme.displayMedium,
                shouldAnimate: !isValidKeyPress),
            currency: inputSelectedCurrency ?? Loc.of(context).usd,
            bottomLabel: inputLabel,
            isToggle: inputSelectedCurrency?.isNotEmpty ?? false),
        const SizedBox(height: Grid.sm),
        _buildRow(
            context,
            Text(
              NumberFormat.simpleCurrency().format(outputAmount),
              style: Theme.of(context).textTheme.displayMedium,
            ),
            currency: outputSelectedCurrency ?? Loc.of(context).usd,
            bottomLabel: Loc.of(context).youGet,
            isToggle: outputSelectedCurrency?.isNotEmpty ?? false),
      ],
    );
  }

  Widget _buildRow(BuildContext context, inputWidget,
      {String currency = '', String bottomLabel = '', bool isToggle = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      isToggle
          ? GestureDetector(
              onTap: onDropdownTap,
              child: _buildRowDetail(context, inputWidget,
                  currency: currency, isToggle: isToggle))
          : _buildRowDetail(context, inputWidget, currency: currency),
      const SizedBox(height: Grid.xxs),
      Text(
        bottomLabel,
        style: Theme.of(context).textTheme.bodyLarge,
      )
    ]);
  }

  Widget _buildRowDetail(BuildContext context, Widget inputWidget,
      {String currency = '', bool isToggle = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        inputWidget,
        const SizedBox(width: Grid.xs),
        Text(
          currency,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        if (isToggle) const Icon(Icons.keyboard_arrow_down)
      ],
    );
  }
}
