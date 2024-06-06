import 'package:auto_size_text/auto_size_text.dart';
import 'package:decimal/decimal.dart';
import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/payment/payment_fee_details.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/async/async_data_widget.dart';
import 'package:didpay/shared/async/async_error_widget.dart';
import 'package:didpay/shared/async/async_loading_widget.dart';
import 'package:didpay/shared/currency_formatter.dart';
import 'package:didpay/shared/header.dart';
import 'package:didpay/shared/next_button.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

class PaymentReviewPage extends HookConsumerWidget {
  final PaymentState paymentState;

  const PaymentReviewPage({required this.paymentState, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteResponse = useState<AsyncValue<Quote>>(const AsyncLoading());
    final orderResponse = useState<AsyncValue<Order>?>(null);

    useEffect(
      () {
        Future.microtask(
          () async => _pollForQuote(ref, quoteResponse),
        );
        return null;
      },
      [],
    );

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: orderResponse.value == null
            ? quoteResponse.value.when(
                data: (quote) => Column(
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
                          padding:
                              const EdgeInsets.symmetric(horizontal: Grid.side),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: Grid.sm),
                              _buildAmounts(context, quote.data),
                              _buildFeeDetails(context, quote.data),
                              _buildPaymentDetails(context),
                            ],
                          ),
                        ),
                      ),
                    ),
                    NextButton(
                      onPressed: () => _submitOrder(
                        context,
                        ref,
                        paymentState,
                        orderResponse,
                      ),
                      title:
                          '${Loc.of(context).pay} ${PaymentFeeDetails.calculateTotalAmount(quote.data)} ${quote.data.payin.currencyCode}',
                    ),
                  ],
                ),
                loading: () => AsyncLoadingWidget(
                  text: Loc.of(context).gettingYourQuote,
                ),
                error: (error, _) => AsyncErrorWidget(
                  text: error.toString(),
                  onRetry: () => _pollForQuote(ref, quoteResponse),
                ),
              )
            : orderResponse.value!.when(
                data: (_) =>
                    AsyncDataWidget(text: Loc.of(context).orderConfirmed),
                loading: () => AsyncLoadingWidget(
                  text: Loc.of(context).confirmingYourOrder,
                ),
                error: (error, _) => AsyncErrorWidget(
                  text: error.toString(),
                  onRetry: () => _submitOrder(
                    context,
                    ref,
                    paymentState,
                    orderResponse,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAmounts(BuildContext context, QuoteData quote) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: AutoSizeText(
                  Decimal.parse(quote.payin.amount)
                      .formatCurrency(quote.payin.currencyCode),
                  style: Theme.of(context).textTheme.headlineMedium,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: Grid.half),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Grid.xxs),
                child: Text(
                  quote.payin.currencyCode,
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
                  Decimal.parse(quote.payout.amount)
                      .formatCurrency(quote.payout.currencyCode),
                  style: Theme.of(context).textTheme.headlineMedium,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: Grid.xs),
              Text(
                quote.payout.currencyCode,
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

  Widget _buildFeeDetails(BuildContext context, QuoteData quote) => Padding(
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
              paymentState.paymentName ?? '',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: Grid.xxs),
            ...?paymentState.formData?.entries.map(
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

  void _pollForQuote(
    WidgetRef ref,
    ValueNotifier<AsyncValue<Quote>> state,
  ) {
    if (paymentState.exchangeId != null && paymentState.selectedPfi != null) {
      ref
          .read(tbdexServiceProvider)
          .pollForQuote(
            ref.read(didProvider),
            paymentState.selectedPfi!,
            paymentState.exchangeId!,
          )
          .then((quote) => state.value = AsyncData(quote))
          .catchError((error, stackTrace) {
        state.value = AsyncError(error, stackTrace);
        throw error;
      });
    }
  }

  void _submitOrder(
    BuildContext context,
    WidgetRef ref,
    PaymentState paymentState,
    ValueNotifier<AsyncValue<Order>?> state,
  ) {
    state.value = const AsyncLoading();
    ref
        .read(tbdexServiceProvider)
        .submitOrder(
          ref.read(didProvider),
          paymentState.selectedPfi,
          paymentState.exchangeId,
        )
        .then((order) async {
      state.value = AsyncData(order);
    }).catchError((error, stackTrace) {
      state.value = AsyncError(error, stackTrace);
      throw error;
    });
  }
}
