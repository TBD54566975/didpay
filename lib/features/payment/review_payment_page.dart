import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/features/payment/payment_confirmation_page.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/tbdex/quote_notifier.dart';
import 'package:didpay/features/tbdex/tbdex_providers.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/fee_details.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/utils/currency_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

class ReviewPaymentPage extends HookConsumerWidget {
  final Rfq rfq;
  final PaymentState paymentState;

  const ReviewPaymentPage({
    required this.rfq,
    required this.paymentState,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    QuoteAsyncNotifier getQuoteNotifier() => ref.read(quoteProvider.notifier);
    final quoteResult = ref.watch(quoteProvider);

    useEffect(
      () {
        Future.delayed(Duration.zero, () {
          ref.read(rfqProvider(rfq));
          getQuoteNotifier().startPolling(rfq.metadata.id);
        });
        return getQuoteNotifier().stopPolling;
      },
      [],
    );

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Grid.side),
          child: quoteResult.when(
            data: (quote) => quote != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(context),
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
                      _buildSubmitButton(context, quote.data),
                    ],
                  )
                : _loading(),
            loading: _loading,
            error: (error, stackTrace) => Center(
              child: Text(
                'Failed to get quote: $error',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loading() => const Center(child: CircularProgressIndicator());

  Widget _buildHeader(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: Grid.xs),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                Loc.of(context).reviewYourPayment,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: Grid.xs),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                Loc.of(context).makeSureInfoIsCorrect,
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

  Widget _buildSubmitButton(BuildContext context, QuoteData quote) =>
      FilledButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const PaymentConfirmationPage(),
            ),
          );
        },
        child: Text(
          '${Loc.of(context).pay} ${FeeDetails.calculateTotalAmount(quote)} ${quote.payin.currencyCode}',
        ),
      );
}
