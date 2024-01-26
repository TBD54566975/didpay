import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:flutter_starter/shared/grid.dart';
import 'package:flutter_starter/shared/number_pad.dart';
import 'package:intl/intl.dart';

class DepositPage extends HookWidget {
  const DepositPage({super.key});

  @override
  Widget build(BuildContext context) {
    final depositAmount = useState<String>('0');

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Grid.side, vertical: Grid.sm),
                  child: Column(
                    children: [
                      buildCurrencyConverter(
                          context, depositAmount, 'MXN', '17'),
                      const SizedBox(height: Grid.xl),
                      // these will come from PFI offerings later
                      buildDepositDetails(context, 'MXN', '17', '0'),
                    ],
                  ),
                ),
              ),
            ),
            Center(child: buildNumberPad(depositAmount)),
            const SizedBox(height: Grid.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Grid.side),
              child: FilledButton(
                onPressed: () {},
                child: Text(Loc.of(context).next),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCurrencyConverter(
      BuildContext context,
      ValueNotifier<String> depositAmount,
      String depositCurrency,
      String exchangeRate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              NumberFormat.simpleCurrency()
                  .format(double.parse(depositAmount.value)),
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(width: Grid.xs),
            Text(
              depositCurrency,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        const SizedBox(height: Grid.xxs),
        Text(
          Loc.of(context).youDeposit,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: Grid.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              NumberFormat.simpleCurrency().format(
                  double.parse(depositAmount.value) /
                      double.parse(exchangeRate)),
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(width: Grid.xs),
            Baseline(
              baseline: 0,
              baselineType: TextBaseline.alphabetic,
              child: Text(
                Loc.of(context).usd,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
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

  Widget buildDepositDetails(
    BuildContext context,
    String depositCurrency,
    String exchangeRate,
    String serviceFee,
  ) {
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
                  '1 ${Loc.of(context).usd} = $exchangeRate $depositCurrency',
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
                  '$serviceFee $depositCurrency',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildNumberPad(ValueNotifier<String> depositAmount) {
    return NumberPad(
      onKeyPressed: (key) {
        depositAmount.value =
            (depositAmount.value == '0') ? key : '${depositAmount.value}$key';
      },
      onDeletePressed: () {
        depositAmount.value = (depositAmount.value.length > 1)
            ? depositAmount.value.substring(0, depositAmount.value.length - 1)
            : '0';
      },
    );
  }
}
