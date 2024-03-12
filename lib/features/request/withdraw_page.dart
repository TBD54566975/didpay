import 'package:didpay/features/currency/currency.dart';
import 'package:didpay/features/currency/payin.dart';
import 'package:didpay/features/currency/payout.dart';
import 'package:didpay/features/home/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:didpay/features/payment/payment_details_page.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/fee_details.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/number_pad.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class WithdrawPage extends HookConsumerWidget {
  const WithdrawPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencies = ref.watch(currencyProvider);

    final payinAmount = useState('0');
    final payoutAmount = useState(0.0);
    final keyPress = useState(PayinKeyPress(0, ''));
    final selectedCurrency = useState<Currency?>(currencies[0]);

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Payin(
                        transactionType: TransactionType.withdraw,
                        amount: payinAmount,
                        keyPress: keyPress,
                        currency: selectedCurrency,
                      ),
                      const SizedBox(height: Grid.sm),
                      Payout(
                        payinAmount: double.tryParse(payinAmount.value) ?? 0.0,
                        transactionType: TransactionType.withdraw,
                        payoutAmount: payoutAmount,
                        currency: selectedCurrency,
                      ),
                      const SizedBox(height: Grid.xl),
                      FeeDetails(
                          payinCurrency: CurrencyCode.usdc.toString(),
                          payoutCurrency:
                              selectedCurrency.value?.code.toString() ?? '',
                          exchangeRate:
                              selectedCurrency.value?.exchangeRate.toString() ??
                                  '',
                          serviceFee: '0')
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: NumberPad(
                onKeyPressed: (key) => keyPress.value =
                    PayinKeyPress(keyPress.value.count + 1, key),
              ),
            ),
            const SizedBox(height: Grid.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Grid.side),
              child: FilledButton(
                onPressed: () {
                  final payoutCurrency =
                      selectedCurrency.value?.code.toString() ?? '';
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PaymentDetailsPage(
                        payinAmount: payinAmount.value,
                        payinCurrency: Loc.of(context).usd,
                        payoutAmount: Currency.formatFromDouble(
                          payoutAmount.value,
                          currency: payoutCurrency,
                        ),
                        payoutCurrency: payoutCurrency,
                        exchangeRate:
                            selectedCurrency.value?.exchangeRate.toString() ??
                                '',
                        transactionType: TransactionType.withdraw,
                      ),
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
}
