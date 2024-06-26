import 'package:decimal/decimal.dart';
import 'package:didpay/features/payin/payin.dart';
import 'package:didpay/features/payment/payment_details_page.dart';
import 'package:didpay/features/payment/payment_fee_details.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/payout/payout.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/error_message.dart';
import 'package:didpay/shared/loading_message.dart';
import 'package:didpay/shared/next_button.dart';
import 'package:didpay/shared/number/number_key_press.dart';
import 'package:didpay/shared/number/number_pad.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

class PaymentAmountPage extends HookConsumerWidget {
  final PaymentState paymentState;

  const PaymentAmountPage({required this.paymentState, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payinAmount = useState<String>('0');
    final payoutAmount = useState<Decimal>(Decimal.zero);
    final keyPress = useState(NumberKeyPress(0, ''));
    final currentPaymentState = useState<PaymentState>(paymentState);
    final selectedPfi = useState<Pfi?>(paymentState.selectedPfi);
    final selectedOffering = useState<Offering?>(paymentState.selectedOffering);
    final offerings =
        useState<AsyncValue<Map<Pfi, List<Offering>>>>(const AsyncLoading());

    useEffect(
      () {
        Future.microtask(
          () async => paymentState.offeringsMap != null
              ? offerings.value = AsyncData({
                  selectedPfi.value!: [selectedOffering.value!],
                })
              : await _getOfferings(ref, currentPaymentState.value, offerings),
        );
        return null;
      },
      [],
    );

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: offerings.value.when(
          data: (data) {
            selectedPfi.value ??= data.keys.first;
            selectedOffering.value ??= data[selectedPfi.value]!.first;

            void onCurrencySelect(pfi, offering) {
              selectedPfi.value = pfi;
              selectedOffering.value = offering;
            }

            currentPaymentState.value = _updatePaymentState(
              currentPaymentState.value,
              payinAmount.value,
              payoutAmount.value,
              selectedPfi.value,
              selectedOffering.value,
              data,
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
                            paymentState: currentPaymentState.value,
                            payinAmount: payinAmount,
                            keyPress: keyPress,
                            onCurrencySelect: onCurrencySelect,
                          ),
                          const SizedBox(height: Grid.sm),
                          Payout(
                            paymentState: currentPaymentState.value,
                            payoutAmount: payoutAmount,
                            onCurrencySelect: onCurrencySelect,
                          ),
                          const SizedBox(height: Grid.xl),
                          PaymentFeeDetails(
                            transactionType: paymentState.transactionType,
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
                NextButton(
                  onPressed: Decimal.parse(payinAmount.value) == Decimal.zero
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PaymentDetailsPage(
                                paymentState: currentPaymentState.value,
                              ),
                            ),
                          ),
                ),
              ],
            );
          },
          loading: () =>
              LoadingMessage(message: Loc.of(context).fetchingOfferings),
          error: (error, stackTrace) => ErrorMessage(
            message: error.toString(),
            onRetry: () =>
                _getOfferings(ref, currentPaymentState.value, offerings),
          ),
        ),
      ),
    );
  }

  PaymentState _updatePaymentState(
    PaymentState currentState,
    String payinAmount,
    Decimal payoutAmount,
    Pfi? selectedPfi,
    Offering? selectedOffering,
    Map<Pfi, List<Offering>> offeringsMap,
  ) =>
      currentState.copyWith(
        payinAmount: Decimal.parse(payinAmount),
        payoutAmount: payoutAmount,
        selectedPfi: selectedPfi,
        selectedOffering: selectedOffering,
        offeringsMap: offeringsMap,
        payinCurrency: selectedOffering?.data.payin.currencyCode ?? '',
        payoutCurrency: selectedOffering?.data.payout.currencyCode ?? '',
        payinMethods: selectedOffering?.data.payin.methods ?? [],
        payoutMethods: selectedOffering?.data.payout.methods ?? [],
        exchangeRate: Decimal.parse(
          selectedOffering?.data.payoutUnitsPerPayinUnit ?? '1',
        ),
        selectedPayinMethod: currentState.moneyAddresses == null
            ? null
            : selectedOffering?.data.payin.methods.firstOrNull,
        selectedPayoutMethod: currentState.moneyAddresses == null
            ? null
            : selectedOffering?.data.payout.methods.firstOrNull,
        formData: currentState.moneyAddresses == null
            ? null
            : {
                selectedOffering?.data.payout.methods.firstOrNull
                        ?.requiredPaymentDetails?.requiredProperties?.first ??
                    '': currentState.moneyAddresses?.first.urn ?? '',
              },
      );

  Future<void> _getOfferings(
    WidgetRef ref,
    PaymentState paymentState,
    ValueNotifier<AsyncValue<Map<Pfi, List<Offering>>>> state,
  ) async {
    state.value = const AsyncLoading();
    try {
      await ref
          .read(tbdexServiceProvider)
          .getOfferings(paymentState, ref.read(pfisProvider))
          .then((offerings) => state.value = AsyncData(offerings));
    } on Exception catch (e) {
      state.value = AsyncError(e, StackTrace.current);
    }
  }
}
