import 'package:auto_size_text/auto_size_text.dart';
import 'package:decimal/decimal.dart';
import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/payment/payment_fee_details.dart';
import 'package:didpay/features/payment/payment_fetch_instructions_widget.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/confirm_dialog.dart';
import 'package:didpay/shared/currency_formatter.dart';
import 'package:didpay/shared/error_message.dart';
import 'package:didpay/shared/header.dart';
import 'package:didpay/shared/loading_message.dart';
import 'package:didpay/shared/next_button.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

class PaymentReviewPage extends HookConsumerWidget {
  final PaymentState paymentState;

  const PaymentReviewPage({
    required this.paymentState,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = useState<AsyncValue<Order>?>(null);
    final orderInstructions =
        useState<AsyncValue<OrderInstructions?>>(const AsyncLoading());

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }

        WidgetsBinding.instance.addPostFrameCallback(
          (_) async {
            final shouldPop = await _showConfirmDialog(context) ?? false;

            if (shouldPop && context.mounted) {
              Navigator.of(context).pop();
            }
          },
        );
      },
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: order.value != null
              ? order.value!.when(
                  data: (_) => PaymentFetchInstructionsWidget(
                    paymentState: paymentState,
                    instructions: orderInstructions,
                    order: order,
                    ref: ref,
                  ),
                  loading: () => LoadingMessage(
                    message: Loc.of(context).confirmingYourOrder,
                  ),
                  error: (error, _) => ErrorMessage(
                    message: error.toString(),
                    onRetry: () => _submitOrder(
                      context,
                      ref,
                      paymentState,
                      order,
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Header(
                      title: Loc.of(context).reviewYourPayment,
                      subtitle: Loc.of(context).makeSureInfoIsCorrect,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Grid.side,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: Grid.sm),
                              _buildAmounts(context, paymentState.quote?.data),
                              _buildFeeDetails(
                                  context, paymentState.quote?.data,),
                              _buildPaymentDetails(context),
                            ],
                          ),
                        ),
                      ),
                    ),
                    NextButton(
                      onPressed: () =>
                          _submitOrder(context, ref, paymentState, order),
                      title:
                          '${Loc.of(context).pay} ${PaymentFeeDetails.calculateTotalAmount(paymentState.quote?.data)} ${paymentState.quote?.data.payin.currencyCode}',
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildAmounts(BuildContext context, QuoteData? quote) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: AutoSizeText(
                  Decimal.parse(quote?.payin.total ?? '0')
                      .formatCurrency(quote?.payin.currencyCode ?? ''),
                  style: Theme.of(context).textTheme.headlineMedium,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: Grid.half),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Grid.xxs),
                child: Text(
                  quote?.payin.currencyCode ?? '',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: Grid.xxs),
          Text(
            Loc.of(context).requestedAmount,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: Grid.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: AutoSizeText(
                  Decimal.parse(quote?.payout.total ?? '0')
                      .formatCurrency(quote?.payout.currencyCode ?? ''),
                  style: Theme.of(context).textTheme.headlineMedium,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: Grid.xs),
              Text(
                quote?.payout.currencyCode ?? '',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: Grid.xxs),
          _buildPayoutLabel(context),
        ],
      );

  Widget _buildPayoutLabel(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    final labels = {
      TransactionType.deposit: Loc.of(context).totalToAccount,
      TransactionType.withdraw: Loc.of(context).totalToYou,
      TransactionType.send: Loc.of(context).totalToRecipient,
    };

    final label =
        labels[paymentState.transactionType] ?? 'unknown transaction type';

    return Text(label, style: style);
  }

  Widget _buildFeeDetails(BuildContext context, QuoteData? quote) => Padding(
        padding: const EdgeInsets.symmetric(vertical: Grid.lg),
        child: PaymentFeeDetails(
          transactionType: paymentState.transactionType,
          quote: quote,
        ),
      );

  Widget _buildPaymentDetails(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: Grid.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              paymentState.paymentDetailsState?.selectedPaymentMethod?.title ??
                  '',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: Grid.xxs),
            ...?paymentState.paymentDetails?.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(
                  bottom: Grid.xxs,
                ),
                child: Text(
                  entry.value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      );

  Future<bool?> _showConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (c) => ConfirmDialog(
        title: Loc.of(c).areYouSure,
        description: Loc.of(c).ifYouGoBackNow,
        confirmText: Loc.of(c).goBack,
        cancelText: Loc.of(c).cancel,
        onConfirm: () async => Navigator.of(c).pop(true),
        onCancel: () async => Navigator.of(c).pop(false),
      ),
    );
  }

  Future<void> _submitOrder(
    BuildContext context,
    WidgetRef ref,
    PaymentState paymentState,
    ValueNotifier<AsyncValue<Order>?> state,
  ) async {
    state.value = const AsyncLoading();

    try {
      final order = await ref.read(tbdexServiceProvider).sendOrder(
            ref.read(didProvider),
            paymentState.paymentAmountState?.pfiDid ?? '',
            paymentState.paymentDetailsState?.exchangeId ?? '',
          );

      if (context.mounted) {
        state.value = AsyncData(order);
      }
    } on Exception catch (e) {
      state.value = AsyncError(e, StackTrace.current);
    }
  }
}
