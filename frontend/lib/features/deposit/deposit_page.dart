import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:flutter_starter/shared/currency_converter.dart';
import 'package:flutter_starter/shared/fee_details.dart';
import 'package:flutter_starter/shared/grid.dart';
import 'package:flutter_starter/shared/number_pad.dart';

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
                      CurrencyConverter(
                          originAmount: depositAmount.value,
                          originCurrency: 'MXN',
                          originLabel: Loc.of(context).youDeposit,
                          destinationCurrency: Loc.of(context).usd,
                          exchangeRate: (1 / 17).toString()),
                      const SizedBox(height: Grid.xl),
                      // these will come from PFI offerings later
                      FeeDetails(
                          originCurrency: Loc.of(context).usd,
                          destinationCurrency: 'MXN',
                          exchangeRate: '17',
                          serviceFee: '0')
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
