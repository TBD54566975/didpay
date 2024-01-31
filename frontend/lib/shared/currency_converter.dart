import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:flutter_starter/shared/grid.dart';
import 'package:intl/intl.dart';

class CurrencyConverter extends HookWidget {
  final String originAmount;
  final String originCurrency;
  final String originLabel;
  final String destinationCurrency;
  final String exchangeRate;

  const CurrencyConverter({
    required this.originAmount,
    required this.originCurrency,
    required this.originLabel,
    required this.destinationCurrency,
    required this.exchangeRate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              NumberFormat.simpleCurrency().format(double.parse(originAmount)),
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(width: Grid.xs),
            Baseline(
              baseline: 0,
              baselineType: TextBaseline.alphabetic,
              child: Text(
                originCurrency,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: Grid.xxs),
        Text(
          originLabel,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: Grid.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              NumberFormat.simpleCurrency().format(
                  double.parse(originAmount) * double.parse(exchangeRate)),
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(width: Grid.xs),
            Text(
              destinationCurrency,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        const SizedBox(height: Grid.xxs),
        Text(
          Loc.of(context).youGet,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}