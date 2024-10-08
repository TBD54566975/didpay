import 'package:didpay/features/dap/dap_state.dart';
import 'package:didpay/features/payin/payin.dart';
import 'package:didpay/features/payment/payment_amount_state.dart';
import 'package:didpay/features/payment/payment_details_page.dart';
import 'package:didpay/features/payment/payment_details_state.dart';
import 'package:didpay/features/payment/payment_fee_details.dart';
import 'package:didpay/features/payment/payment_method.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/payout/payout.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/transaction/transaction.dart';
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
  final DapState? dapState;

  const PaymentAmountPage({
    required this.paymentState,
    this.dapState,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyPress = useState(NumberKeyPress(0, ''));
    final offerings =
        useState<AsyncValue<Map<Pfi, List<Offering>>>>(const AsyncLoading());
    final state = useState<PaymentAmountState>(
      paymentState.paymentAmountState ?? PaymentAmountState(),
    );

    useEffect(
      () {
        Future.delayed(Duration.zero, () async {
          if (context.mounted) {
            await _getOfferings(context, ref, dapState?.currencies, offerings);
          }
        });

        return null;
      },
      [],
    );

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: offerings.value.when(
          data: (offeringsMap) {
            if (state.value.offeringsMap == null) {
              state.value = state.value.copyWith(
                pfiDid: offeringsMap.keys.first.did,
                selectedOffering: offeringsMap.values.first.first,
                offeringsMap: offeringsMap,
              );
            }

            return _buildPage(context, keyPress, state);
          },
          loading: () =>
              LoadingMessage(message: Loc.of(context).fetchingOfferings),
          error: (error, stackTrace) => ErrorMessage(
            message: error.toString(),
            onRetry: () => _getOfferings(
              context,
              ref,
              dapState?.currencies,
              offerings,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(
    BuildContext context,
    ValueNotifier<NumberKeyPress> keyPress,
    ValueNotifier<PaymentAmountState?> state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(
                left: Grid.side,
                right: Grid.side,
                top: Grid.xxs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Payin(
                    transactionType: paymentState.transactionType,
                    state: state,
                    keyPress: keyPress,
                  ),
                  const SizedBox(height: Grid.sm),
                  Payout(
                    transactionType: paymentState.transactionType,
                    state: state,
                  ),
                  const SizedBox(height: Grid.lg),
                  PaymentFeeDetails(
                    transactionType: paymentState.transactionType,
                    offering: state.value?.selectedOffering?.data,
                  ),
                ],
              ),
            ),
          ),
        ),
        Center(
          child: NumberPad(
            onKeyPressed: (key) =>
                keyPress.value = NumberKeyPress(keyPress.value.count + 1, key),
          ),
        ),
        const SizedBox(height: Grid.xs),
        NextButton(
          onPressed: state.value?.payinAmount == null ||
                  state.value?.payinAmount == '0'
              ? null
              : () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        final paymentCurrency = paymentState.transactionType ==
                                TransactionType.deposit
                            ? state.value?.payinCurrency
                            : state.value?.payoutCurrency;

                        final paymentMethods = paymentState.transactionType ==
                                TransactionType.deposit
                            ? state.value?.selectedOffering?.data.payin.methods
                                .map(PaymentMethod.fromPayinMethod)
                                .toList()
                            : state.value?.selectedOffering?.data.payout.methods
                                .map(PaymentMethod.fromPayoutMethod)
                                .toList();

                        final paymentDetailsState =
                            (paymentState.paymentDetailsState ??
                                    PaymentDetailsState())
                                .copyWith(
                          paymentCurrency: paymentCurrency,
                          paymentMethods:
                              dapState?.filterPaymentMethods(paymentMethods) ??
                                  paymentMethods,
                        );

                        return PaymentDetailsPage(
                          paymentState: paymentState.copyWith(
                            paymentAmountState: state.value,
                            paymentDetailsState: paymentDetailsState,
                          ),
                          dapState: dapState?.copyWith(
                            selectedAddress: dapState
                                ?.getSelectedMoneyAddress(paymentCurrency),
                          ),
                        );
                      },
                    ),
                  ),
        ),
      ],
    );
  }

  Future<void> _getOfferings(
    BuildContext context,
    WidgetRef ref,
    List<String>? payoutCurrencies,
    ValueNotifier<AsyncValue<Map<Pfi, List<Offering>>>> state,
  ) async {
    state.value = const AsyncLoading();
    try {
      final offerings = await ref.read(tbdexServiceProvider).getOfferings(
            ref.read(pfisProvider),
            payoutCurrencies: payoutCurrencies,
          );

      if (context.mounted) {
        state.value = AsyncData(offerings);
      }
    } on Exception catch (e) {
      if (context.mounted) {
        state.value = AsyncError(e, StackTrace.current);
      }
    }
  }
}
