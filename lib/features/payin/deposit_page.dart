import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/features/payin/payin.dart';
import 'package:didpay/features/payin/payin_details_page.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/payout/payout.dart';
import 'package:didpay/features/tbdex/rfq_state.dart';
import 'package:didpay/features/tbdex/tbdex_providers.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/fee_details.dart';
import 'package:didpay/shared/number_pad.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/utils/currency_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

class DepositPage extends HookConsumerWidget {
  final RfqState rfqState;

  const DepositPage({required this.rfqState, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO(ethan-tbd): filter offerings with STORED_BALANCE as payout, https://github.com/TBD54566975/didpay/issues/132
    final offerings = ref.watch(offeringsProvider);

    final payinAmount = useState('0');
    final payoutAmount = useState<double>(0);
    final keyPress = useState(PayinKeyPress(0, ''));
    final selectedOffering = useState<Offering?>(null);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: offerings.when(
          data: (offerings) {
            selectedOffering.value ??= offerings.first;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Grid.side,
                        vertical: Grid.xs,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Payin(
                            transactionType: TransactionType.deposit,
                            amount: payinAmount,
                            keyPress: keyPress,
                            selectedOffering: selectedOffering,
                            offerings: offerings,
                          ),
                          const SizedBox(height: Grid.sm),
                          Payout(
                            payinAmount:
                                double.tryParse(payinAmount.value) ?? 0.0,
                            transactionType: TransactionType.deposit,
                            payoutAmount: payoutAmount,
                            selectedOffering: selectedOffering,
                            offerings: offerings,
                          ),
                          const SizedBox(height: Grid.xl),
                          FeeDetails(
                            payinCurrency: selectedOffering
                                    .value?.data.payin.currencyCode ??
                                '',
                            payoutCurrency: selectedOffering
                                    .value?.data.payout.currencyCode ??
                                '',
                            exchangeRate: selectedOffering
                                    .value?.data.payoutUnitsPerPayinUnit ??
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
                  rfqState,
                  payinAmount.value,
                  CurrencyUtil.formatFromDouble(
                    payoutAmount.value,
                    currency:
                        selectedOffering.value?.data.payout.currencyCode ?? '',
                  ),
                  selectedOffering.value,
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text(
              'failed to retrieve offerings: $error',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(
    BuildContext context,
    RfqState rfqState,
    String payinAmount,
    String payoutAmount,
    Offering? selectedOffering,
  ) {
    final disabled = double.tryParse(payinAmount) == 0;

    void onPressed() => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PayinDetailsPage(
              rfqState: rfqState.copyWith(
                payinAmount: payinAmount,
                offering: selectedOffering,
                payinMethod: selectedOffering?.data.payin.methods.firstOrNull,
                payoutMethod: selectedOffering?.data.payout.methods.firstOrNull,
              ),
              paymentState: PaymentState(
                payoutAmount: payoutAmount,
                payinCurrency: selectedOffering?.data.payin.currencyCode ?? '',
                payoutCurrency:
                    selectedOffering?.data.payout.currencyCode ?? '',
                exchangeRate:
                    selectedOffering?.data.payoutUnitsPerPayinUnit ?? '',
                transactionType: TransactionType.deposit,
                payinMethods: selectedOffering?.data.payin.methods ?? [],
              ),
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
