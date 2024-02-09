import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_starter/features/currency/currency_converter.dart';
import 'package:flutter_starter/features/currency/currency_modal.dart';
import 'package:flutter_starter/features/payments/payment_details_page.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:flutter_starter/shared/fee_details.dart';
import 'package:flutter_starter/shared/theme/grid.dart';
import 'package:flutter_starter/shared/number_pad.dart';
import 'package:flutter_starter/shared/utils/number_pad_input_validation_util.dart';

// replace with actual currency list
final supportedCurrencyList = [
  {'label': 'USD', 'icon': Icons.attach_money, 'exchangeRate': 1},
  {'label': 'MXN', 'icon': Icons.attach_money, 'exchangeRate': 17},
  {'label': 'BTC', 'icon': Icons.currency_bitcoin, 'exchangeRate': 0.000024}
];

class WithdrawPage extends HookWidget {
  const WithdrawPage({super.key});

  @override
  Widget build(BuildContext context) {
    final withdrawAmount = useState<String>('0');
    final isValidKeyPress = useState<bool>(true);
    final selectedCurrencyItem =
        useState<Map<String, Object>>(supportedCurrencyList[1]);

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
                        inputAmount: double.parse('0${withdrawAmount.value}'),
                        inputLabel: Loc.of(context).youWithdraw,
                        outputSelectedCurrency:
                            selectedCurrencyItem.value['label'].toString(),
                        outputAmount:
                            (double.parse('0${withdrawAmount.value}') *
                                double.parse(selectedCurrencyItem
                                    .value['exchangeRate']
                                    .toString())),
                        isValidKeyPress: isValidKeyPress.value,
                        onDropdownTap: () {
                          CurrencyModal.show(
                              context,
                              (value) => selectedCurrencyItem.value =
                                  supportedCurrencyList.firstWhere(
                                      (element) => element['label'] == value),
                              supportedCurrencyList,
                              selectedCurrencyItem.value['label'].toString());
                        },
                      ),
                      const SizedBox(height: Grid.xl),
                      // these will come from PFI offerings later
                      FeeDetails(
                          originCurrency: Loc.of(context).usd,
                          destinationCurrency:
                              selectedCurrencyItem.value['label'].toString(),
                          exchangeRate: selectedCurrencyItem
                              .value['exchangeRate']
                              .toString(),
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
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PaymentDetailsPage(),
                    ),
                  );
                },
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
