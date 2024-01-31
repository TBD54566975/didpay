import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:flutter_starter/shared/currency_converter.dart';
import 'package:flutter_starter/shared/fee_details.dart';
import 'package:flutter_starter/shared/grid.dart';
import 'package:flutter_starter/shared/number_pad.dart';

class WithdrawPage extends HookWidget {
  const WithdrawPage({super.key});

  @override
  Widget build(BuildContext context) {
    final withdrawAmount = useState<String>('0');

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
                          withdrawAmount,
                          Loc.of(context).usd,
                          Loc.of(context).youWithdraw,
                          'MXN',
                          '17'),
                      const SizedBox(height: Grid.xl),
                      // these will come from PFI offerings later
                      buildFeeDetails(Loc.of(context).usd, 'MXN', '17', '0')
                    ],
                  ),
                ),
              ),
            ),
            Center(child: buildNumberPad(withdrawAmount)),
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
      ValueNotifier<String> withdrawAmount,
      String withdrawCurrency,
      String withdrawLabel,
      String receiptCurrency,
      String exchangeRate) {
    return CurrencyConverter(
        originAmount: withdrawAmount.value,
        originCurrency: withdrawCurrency,
        originLabel: withdrawLabel,
        destinationCurrency: receiptCurrency,
        exchangeRate: exchangeRate);
  }

  Widget buildFeeDetails(String withdrawCurrency, String receiptCurrency,
      String exchangeRate, String serviceFee) {
    return FeeDetails(
        originCurrency: withdrawCurrency,
        destinationCurrency: receiptCurrency,
        exchangeRate: exchangeRate,
        serviceFee: serviceFee);
  }

  Widget buildNumberPad(ValueNotifier<String> withdrawAmount) {
    return NumberPad(
      onKeyPressed: (key) {
        withdrawAmount.value =
            (withdrawAmount.value == '0') ? key : '${withdrawAmount.value}$key';
      },
      onDeletePressed: () {
        withdrawAmount.value = (withdrawAmount.value.length > 1)
            ? withdrawAmount.value.substring(0, withdrawAmount.value.length - 1)
            : '0';
      },
    );
  }
}
