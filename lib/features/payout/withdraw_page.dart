import 'package:didpay/features/payin/payin.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/payout/payout.dart';
import 'package:didpay/features/payout/payout_details_page.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/tbdex/rfq_state.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/async_error_widget.dart';
import 'package:didpay/shared/async_loading_widget.dart';
import 'package:didpay/shared/fee_details.dart';
import 'package:didpay/shared/number_pad.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/utils/currency_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

class WithdrawPage extends HookConsumerWidget {
  final RfqState rfqState;

  const WithdrawPage({required this.rfqState, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO(ethan-tbd): filter offerings with STORED_BALANCE as payin, https://github.com/TBD54566975/didpay/issues/132

    final payinAmount = useState('0');
    final payoutAmount = useState<double>(0);
    final keyPress = useState(PayinKeyPress(0, ''));
    final selectedOffering = useState<Offering?>(null);
    final getOfferingsState =
        useState<AsyncValue<List<Offering>>>(const AsyncLoading());

    useEffect(
      () {
        _getOfferings(ref, getOfferingsState);
        return null;
      },
      [],
    );

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: getOfferingsState.value.when(
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
                        vertical: Grid.sm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Payin(
                            transactionType: TransactionType.withdraw,
                            amount: payinAmount,
                            keyPress: keyPress,
                            selectedOffering: selectedOffering,
                            offerings: offerings,
                          ),
                          const SizedBox(height: Grid.sm),
                          Payout(
                            payinAmount:
                                double.tryParse(payinAmount.value) ?? 0.0,
                            transactionType: TransactionType.withdraw,
                            payoutAmount: payoutAmount,
                            selectedOffering: selectedOffering,
                            offerings: offerings,
                          ),
                          const SizedBox(height: Grid.xl),
                          FeeDetails(
                            transactionType: TransactionType.withdraw,
                            offering: selectedOffering.value?.data,
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
                    currency:
                        selectedOffering.value?.data.payout.currencyCode ?? '',
                  ),
                  selectedOffering.value,
                  // TODO(ethan-tbd): get pfi from selectedOffering
                  ref.read(pfisProvider)[0],
                ),
              ],
            );
          },
          loading: () =>
              AsyncLoadingWidget(text: Loc.of(context).fetchingOfferings),
          error: (error, stackTrace) => AsyncErrorWidget(
            text: error.toString(),
            onRetry: () => _getOfferings(ref, getOfferingsState),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(
    BuildContext context,
    String payinAmount,
    String payoutAmount,
    Offering? selectedOffering,
    Pfi pfi,
  ) {
    final disabled = double.tryParse(payinAmount) == 0;

    void onPressed() => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PayoutDetailsPage(
              rfqState: rfqState.copyWith(
                payinAmount: payinAmount,
                offering: selectedOffering,
                payinMethod: selectedOffering?.data.payin.methods.firstOrNull,
                payoutMethod: selectedOffering?.data.payout.methods.firstOrNull,
              ),
              paymentState: PaymentState(
                pfi: pfi,
                payoutAmount: payoutAmount,
                payinCurrency: selectedOffering?.data.payin.currencyCode ?? '',
                payoutCurrency:
                    selectedOffering?.data.payout.currencyCode ?? '',
                exchangeRate:
                    selectedOffering?.data.payoutUnitsPerPayinUnit ?? '',
                transactionType: TransactionType.withdraw,
                payoutMethods: selectedOffering?.data.payout.methods ?? [],
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

  void _getOfferings(
    WidgetRef ref,
    ValueNotifier<AsyncValue<List<Offering>>> state,
  ) {
    state.value = const AsyncLoading();
    ref
        .read(tbdexServiceProvider)
        .getOfferings(ref.read(pfisProvider))
        .then((offerings) => state.value = AsyncData(offerings))
        .catchError((error, stackTrace) {
      state.value = AsyncError(error, stackTrace);
      throw error;
    });
  }
}
