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
import 'package:didpay/shared/currency_formatter.dart';
import 'package:didpay/shared/number_pad.dart';
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
    final payinAmount = useState('0');
    final payoutAmount = useState<double>(0);
    final keyPress = useState(PayinKeyPress(0, ''));
    final selectedPfi = useState<Pfi?>(null);
    final selectedOffering = useState<Offering?>(null);
    final getOfferingsState =
        useState<AsyncValue<Map<Pfi, List<Offering>>>>(const AsyncLoading());

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
          data: (offeringsMap) {
            selectedPfi.value ??= offeringsMap.keys.first;
            selectedOffering.value ??= offeringsMap[selectedPfi.value]!.first;

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
                            transactionType: transactionType,
                            amount: payinAmount,
                            keyPress: keyPress,
                            selectedPfi: selectedPfi,
                            selectedOffering: selectedOffering,
                            offeringsMap: offeringsMap,
                          ),
                          const SizedBox(height: Grid.sm),
                          Payout(
                            payinAmount:
                                double.tryParse(payinAmount.value) ?? 0.0,
                            transactionType: transactionType,
                            payoutAmount: payoutAmount,
                            selectedPfi: selectedPfi,
                            selectedOffering: selectedOffering,
                            offeringsMap: offeringsMap,
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
                        PayinKeyPress(keyPress.value.count + 1, key),
                  ),
                ),
                const SizedBox(height: Grid.sm),
                _buildNextButton(
                  context,
                  payinAmount.value,
                  Decimal.parse(payoutAmount.value.toString()).formatCurrency(
                    selectedOffering.value?.data.payout.currencyCode ?? '',
                  ),
                  selectedPfi.value,
                  selectedOffering.value,
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
    Pfi? selectedPfi,
    Offering? selectedOffering,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Grid.side),
        child: FilledButton(
          onPressed: double.tryParse(payinAmount) == 0
              ? null
              : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PaymentDetailsPage(
                        paymentState: PaymentState(
                          transactionType: transactionType,
                          payinAmount: payinAmount,
                          payoutAmount: payoutAmount,
                          payinCurrency:
                              selectedOffering?.data.payin.currencyCode ?? '',
                          payoutCurrency:
                              selectedOffering?.data.payout.currencyCode ?? '',
                          exchangeRate:
                              selectedOffering?.data.payoutUnitsPerPayinUnit ??
                                  '',
                          selectedPfi: selectedPfi ?? const Pfi(did: ''),
                          selectedOffering: selectedOffering,
                          payinMethods:
                              selectedOffering?.data.payin.methods ?? [],
                          payoutMethods:
                              selectedOffering?.data.payout.methods ?? [],
                        ),
                      ),
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
