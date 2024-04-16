import 'package:didpay/features/currency/currency.dart';
import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/features/payin/payin.dart';
import 'package:didpay/features/payment/payment_method.dart';
import 'package:didpay/features/payout/payout.dart';
import 'package:didpay/features/payout/payout_details_page.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/fee_details.dart';
import 'package:didpay/shared/number_pad.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/utils/currency_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class WithdrawPage extends HookConsumerWidget {
  const WithdrawPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO(ethan-tbd): replace providers with actual offering when tbdex is in
    final currencies = ref.watch(currencyProvider);
    final payoutMethods = ref.read(paymentMethodProvider);

    final payinAmount = useState('0');
    final payoutAmount = useState<double>(0);
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
                    horizontal: Grid.side,
                    vertical: Grid.sm,
                  ),
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
                        serviceFee: '0',
                      ),
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
            _buildNextButton(
              context,
              payinAmount.value,
              CurrencyUtil.formatFromDouble(
                payoutAmount.value,
                currency: (selectedCurrency.value?.code.toString() ?? '')
                    .toUpperCase(),
              ),
              selectedCurrency.value,
              payoutMethods,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton(
    BuildContext context,
    String payinAmount,
    String payoutAmount,
    Currency? selectedCurrency,
    List<PaymentMethod>? payoutMethods,
  ) {
    final disabled = double.tryParse(payinAmount) == 0;

    void onPressed() => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PayoutDetailsPage(
              payinAmount: payinAmount,
              payoutAmount: payoutAmount,
              payinCurrency: selectedCurrency?.code.toString() ?? '',
              payoutCurrency: CurrencyCode.usdc.toString(),
              exchangeRate: selectedCurrency?.exchangeRate.toString() ?? '',
              offeringId: '',
              transactionType: TransactionType.deposit,
              payoutMethods: payoutMethods ?? [],
            ),
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Grid.side),
      child: FilledButton(
        onPressed: disabled ? null : onPressed,
        child: Text(Loc.of(context).next),
      ),
    );
  }
}
