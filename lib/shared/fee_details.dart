import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';

class FeeDetails extends HookWidget {
  final String payinCurrency;
  final String payoutCurrency;
  final String exchangeRate;
  final String serviceFee;
  final String total;

  const FeeDetails({
    required this.payinCurrency,
    required this.payoutCurrency,
    required this.exchangeRate,
    required this.serviceFee,
    this.total = '',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '1 $payinCurrency = $exchangeRate $payoutCurrency',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: Grid.xs),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  Loc.of(context).serviceFee,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '$serviceFee $payoutCurrency',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          if (total.isNotEmpty)
            Column(
              children: [
                const SizedBox(height: Grid.xs),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        Loc.of(context).total,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '$total $payoutCurrency',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
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
