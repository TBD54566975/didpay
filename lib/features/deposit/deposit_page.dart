import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:didpay/features/currency/currency_converter.dart';
import 'package:didpay/features/currency/currency_modal.dart';
import 'package:didpay/features/payments/payment_details_page.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/fee_details.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/number_pad.dart';
import 'package:didpay/shared/utils/number_pad_input_validation_util.dart';

// replace with actual currency list
final supportedCurrencyList = [
  {'label': 'USD', 'icon': Icons.attach_money, 'exchangeRate': 1},
  {'label': 'MXN', 'icon': Icons.attach_money, 'exchangeRate': 17},
  {'label': 'BTC', 'icon': Icons.currency_bitcoin, 'exchangeRate': 0.000024}
];

class DepositPage extends HookWidget {
  const DepositPage({super.key});

  @override
  Widget build(BuildContext context) {
    final depositAmount = useState<String>('0');
    final isValidKeyPress = useState<bool>(true);
    final selectedCurrencyItem =
        useState<Map<String, Object>>(supportedCurrencyList[1]);

    return Scaffold(
      appBar: AppBar(scrolledUnderElevation: 0),
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
                        inputAmount: double.parse('0${depositAmount.value}'),
                        inputSelectedCurrency:
                            selectedCurrencyItem.value['label'].toString(),
                        inputLabel: Loc.of(context).youDeposit,
                        outputAmount: (double.parse('0${depositAmount.value}') /
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
            Center(child: buildNumberPad(depositAmount, isValidKeyPress)),
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

  Widget buildNumberPad(ValueNotifier<String> depositAmount,
      ValueNotifier<bool> isValidKeyPress) {
    return NumberPad(
      onKeyPressed: (key) {
        isValidKeyPress.value = true;
        isValidKeyPress.value = NumberPadInputValidationUtil.validateKeyPress(
            depositAmount.value, key);

        if (isValidKeyPress.value) {
          depositAmount.value =
              (depositAmount.value == '0') ? key : '${depositAmount.value}$key';
        }
      },
      onDeletePressed: () {
        isValidKeyPress.value = true;
        isValidKeyPress.value =
            NumberPadInputValidationUtil.validateDeletePress(
                depositAmount.value);

        if (isValidKeyPress.value) {
          depositAmount.value = (depositAmount.value.length > 1)
              ? depositAmount.value.substring(0, depositAmount.value.length - 1)
              : '0';
        }
      },
    );
  }
}
