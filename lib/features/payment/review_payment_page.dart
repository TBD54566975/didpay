import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/features/payment/payment_confirmation_page.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/tbdex/quote_notifier.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/error_state.dart';
import 'package:didpay/shared/fee_details.dart';
import 'package:didpay/shared/async_loading_widget.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/utils/currency_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

class ReviewPaymentPage extends HookConsumerWidget {
  final String exchangeId;
  final PaymentState paymentState;

  const ReviewPaymentPage({
    required this.exchangeId,
    required this.paymentState,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteStatus = ref.watch(quoteProvider);
    QuoteAsyncNotifier getQuoteNotifier() => ref.read(quoteProvider.notifier);

    useEffect(
      () {
        Future.delayed(
          Duration.zero,
          () => getQuoteNotifier().startPolling(exchangeId, paymentState.pfi),
        );
        return getQuoteNotifier().stopPolling;
      },
      [],
    );

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: quoteStatus.when(
          data: (quote) => quote != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Grid.side),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(
                        context,
                        Loc.of(context).reviewYourPayment,
                        Loc.of(context).makeSureInfoIsCorrect,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
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
                      _buildSubmitButton(context, ref, quote),
                    ],
                  ),
                )
              : AsyncLoadingWidget(text: Loc.of(context).gettingYourQuote),
          loading: () =>
              AsyncLoadingWidget(text: Loc.of(context).gettingYourQuote),
          error: (error, _) => ErrorState(
            text: error.toString(),
            onRetry: () => ref.read(quoteProvider.notifier).startPolling(
                  exchangeId,
                  paymentState.pfi,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title, String subtitle) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: Grid.xs),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: Grid.xs),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );

  Widget _buildAmounts(BuildContext context, QuoteData quote) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: AutoSizeText(
                  CurrencyUtil.formatFromString(
                    quote.payin.amount,
                    currency: quote.payin.currencyCode.toUpperCase(),
                  ),
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
                  quote.payout.amount,
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
        child: FeeDetails(
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

  Widget _buildSubmitButton(BuildContext context, WidgetRef ref, Quote quote) =>
      FilledButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const PaymentConfirmationPage(),
            ),
          );
        },
        child: Text(
          '${Loc.of(context).pay} ${FeeDetails.calculateTotalAmount(quote.data)} ${quote.data.payin.currencyCode}',
        ),
      );
}
