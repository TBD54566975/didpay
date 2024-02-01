import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:flutter_starter/shared/currency_converter.dart';
import 'package:flutter_starter/shared/fee_details.dart';
import 'package:flutter_starter/shared/grid.dart';
import 'package:flutter_starter/shared/number_pad.dart';
import 'package:flutter_starter/shared/utils/number_pad_input_validation_util.dart';

class WithdrawPage extends HookWidget {
  const WithdrawPage({super.key});

  @override
  Widget build(BuildContext context) {
    final withdrawAmount = useState<String>('0');
    final isValidKeyPress = useState<bool>(true);

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
                        originAmount: withdrawAmount.value,
                        originCurrency: Loc.of(context).usd,
                        originLabel: Loc.of(context).youWithdraw,
                        destinationCurrency: 'MXN',
                        exchangeRate: '17',
                        isValidKeyPress: isValidKeyPress.value,
                      ),
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
            Center(child: buildNumberPad(withdrawAmount, isValidKeyPress)),
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

  Widget buildNumberPad(ValueNotifier<String> withdrawAmount,
      ValueNotifier<bool> isValidKeyPress) {
    return NumberPad(
      onKeyPressed: (key) {
        isValidKeyPress.value = true;
        isValidKeyPress.value = NumberPadInputValidationUtil.validateKeyPress(
            withdrawAmount.value, key);

        if (isValidKeyPress.value) {
          withdrawAmount.value = (withdrawAmount.value == '0')
              ? key
              : '${withdrawAmount.value}$key';
        }
      },
      onDeletePressed: () {
        isValidKeyPress.value = true;
        isValidKeyPress.value =
            NumberPadInputValidationUtil.validateDeletePress(
                withdrawAmount.value);

        if (isValidKeyPress.value) {
          withdrawAmount.value = (withdrawAmount.value.length > 1)
              ? withdrawAmount.value
                  .substring(0, withdrawAmount.value.length - 1)
              : '0';
        }
      },
    );
  }
}
