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
import 'package:didpay/shared/async/async_error_widget.dart';
import 'package:didpay/shared/async/async_loading_widget.dart';
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
    final selectedPfi = useState<Pfi?>(paymentState.selectedPfi);
    final selectedOffering = useState<Offering?>(paymentState.selectedOffering);
    final offerings =
        useState<AsyncValue<Map<Pfi, List<Offering>>>>(const AsyncLoading());

    useEffect(
      () {
        Future.microtask(
          () async =>
              selectedOffering.value != null && selectedPfi.value != null
                  ? offerings.value = AsyncData({
                      selectedPfi.value!: [selectedOffering.value!],
                    })
                  : await _getOfferings(ref, offerings),
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

            final state = paymentState.copyWith(
              payinAmount: Decimal.parse(payinAmount.value),
              payoutAmount: payoutAmount.value,
              selectedPfi: selectedPfi.value,
              selectedOffering: selectedOffering.value,
              offeringsMap: data,
              payinCurrency:
                  selectedOffering.value?.data.payin.currencyCode ?? '',
              payoutCurrency:
                  selectedOffering.value?.data.payout.currencyCode ?? '',
              payinMethods: selectedOffering.value?.data.payin.methods ?? [],
              payoutMethods: selectedOffering.value?.data.payout.methods ?? [],
              exchangeRate: Decimal.parse(
                selectedOffering.value?.data.payoutUnitsPerPayinUnit ?? '1',
              ),
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
                            paymentState: state,
                            payinAmount: payinAmount,
                            keyPress: keyPress,
                            onCurrencySelect: onCurrencySelect,
                          ),
                          const SizedBox(height: Grid.sm),
                          Payout(
                            paymentState: state,
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
                  onPressed: paymentState.payinAmount == Decimal.zero
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PaymentDetailsPage(
                                paymentState: paymentState,
                              ),
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
            onRetry: () => _getOfferings(ref, offerings),
          ),
        ),
      ),
    );
  }

  Future<void> _getOfferings(
    WidgetRef ref,
    ValueNotifier<AsyncValue<Map<Pfi, List<Offering>>>> state,
  ) async {
    state.value = const AsyncLoading();
    try {
      await ref
          .read(tbdexServiceProvider)
          .getOfferings(ref.read(pfisProvider))
          .then((offerings) => state.value = AsyncData(offerings));
    } on Exception catch (e) {
      state.value = AsyncError(e, StackTrace.current);
    }
  }
}
