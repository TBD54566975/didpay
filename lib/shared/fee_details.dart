import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';

class FeeDetails extends HookWidget {
  final String originCurrency;
  final String destinationCurrency;
  final String
      exchangeRate; // from origin -> destination (ie. destination / origin = exchangeRate)
  final String serviceFee;
  final String total;

  const FeeDetails({
    required this.originCurrency,
    required this.destinationCurrency,
    required this.exchangeRate,
    required this.serviceFee,
    this.total = '',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(15.0),
      ),
      padding: const EdgeInsets.all(Grid.xs),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  Loc.of(context).estRate,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '1 $originCurrency = $exchangeRate $destinationCurrency',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: Grid.sm),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  Loc.of(context).serviceFee,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '$serviceFee $destinationCurrency',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          if (total.isNotEmpty)
            Column(
              children: [
                const SizedBox(height: Grid.sm),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        Loc.of(context).total,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '$total $destinationCurrency',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ],
            )
        ],
      ),
    );
  }
}
