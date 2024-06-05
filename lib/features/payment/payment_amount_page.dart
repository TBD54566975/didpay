import 'package:decimal/decimal.dart';
import 'package:didpay/features/countries/countries.dart';
import 'package:didpay/features/payin/payin.dart';
import 'package:didpay/features/payment/payment_details_page.dart';
import 'package:didpay/features/payment/payment_fee_details.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/payout/payout.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/async/async_error_widget.dart';
import 'package:didpay/shared/async/async_loading_widget.dart';
import 'package:didpay/shared/number/number_key_press.dart';
import 'package:didpay/shared/number/number_pad.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

class PaymentAmountPage extends HookConsumerWidget {
  final TransactionType transactionType;
  final Country? country;

  const PaymentAmountPage({
    required this.transactionType,
    this.country,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payinAmount = useState<String>('0');
    final payoutAmount = useState<Decimal>(Decimal.zero);
    final keyPress = useState(NumberKeyPress(0, ''));
    final selectedPfi = useState<Pfi?>(null);
    final selectedOffering = useState<Offering?>(null);
    final offeringsResponse =
        useState<AsyncValue<Map<Pfi, List<Offering>>>>(const AsyncLoading());

    useEffect(
      () {
        _getOfferings(ref, offeringsResponse);
        return null;
      },
      [],
    );

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: offeringsResponse.value.when(
          data: (offeringsMap) {
            selectedPfi.value ??= offeringsMap.keys.first;
            selectedOffering.value ??= offeringsMap[selectedPfi.value]!.first;

            void onCurrencySelect(pfi, offering) {
              selectedPfi.value = pfi;
              selectedOffering.value = offering;
            }

            final paymentState = PaymentState(
              payinAmount: Decimal.parse(payinAmount.value),
              transactionType: transactionType,
              selectedPfi: selectedPfi.value,
              selectedOffering: selectedOffering.value,
              offeringsMap: offeringsMap,
            );

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
                            paymentState: paymentState,
                            payinAmount: payinAmount,
                            keyPress: keyPress,
                            onCurrencySelect: onCurrencySelect,
                          ),
                          const SizedBox(height: Grid.sm),
                          Payout(
                            paymentState: paymentState,
                            payoutAmount: payoutAmount,
                            onCurrencySelect: onCurrencySelect,
                          ),
                          const SizedBox(height: Grid.xl),
                          PaymentFeeDetails(
                            transactionType: transactionType,
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
                        NumberKeyPress(keyPress.value.count + 1, key),
                  ),
                ),
                const SizedBox(height: Grid.sm),
                _buildNextButton(
                  context,
                  paymentState.copyWith(
                    payinAmount: Decimal.parse(payinAmount.value),
                    payoutAmount: payoutAmount.value,
                    selectedPfi: selectedPfi.value,
                    selectedOffering: selectedOffering.value,
                    payinCurrency:
                        selectedOffering.value?.data.payin.currencyCode ?? '',
                    payoutCurrency:
                        selectedOffering.value?.data.payout.currencyCode ?? '',
                    payinMethods:
                        selectedOffering.value?.data.payin.methods ?? [],
                    payoutMethods:
                        selectedOffering.value?.data.payout.methods ?? [],
                    exchangeRate: Decimal.parse(
                      selectedOffering.value?.data.payoutUnitsPerPayinUnit ??
                          '1',
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () =>
              AsyncLoadingWidget(text: Loc.of(context).fetchingOfferings),
          error: (error, stackTrace) => AsyncErrorWidget(
            text: error.toString(),
            onRetry: () => _getOfferings(ref, offeringsResponse),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(
    BuildContext context,
    PaymentState paymentState,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Grid.side),
        child: FilledButton(
          onPressed: paymentState.payinAmount == Decimal.zero
              ? null
              : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          PaymentDetailsPage(paymentState: paymentState),
                    ),
                  ),
          child: Text(Loc.of(context).next),
        ),
      );

  void _getOfferings(
    WidgetRef ref,
    ValueNotifier<AsyncValue<Map<Pfi, List<Offering>>>> state,
  ) {
    state.value = const AsyncLoading();
    ref
        .read(tbdexServiceProvider)
        .getOfferings(ref.read(pfisProvider))
        .then((offeringsMap) => state.value = AsyncData(offeringsMap))
        .catchError((error, stackTrace) {
      state.value = AsyncError(error, stackTrace);
      throw error;
    });
  }
}
