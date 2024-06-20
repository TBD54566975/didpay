import 'package:auto_size_text/auto_size_text.dart';
import 'package:decimal/decimal.dart';
import 'package:didpay/features/app/app.dart';
import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/payment/payment_fee_details.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/tbdex/tbdex_quote_notifier.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/confirmation_message.dart';
import 'package:didpay/shared/currency_formatter.dart';
import 'package:didpay/shared/error_message.dart';
import 'package:didpay/shared/exit_dialog.dart';
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

  const PaymentReviewPage({required this.paymentState, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quote = useState<AsyncValue<Quote?>>(ref.watch(quoteProvider));

    final order = useState<AsyncValue<Order>?>(null);

    TbdexQuoteNotifier getQuoteNotifier() => ref.read(quoteProvider.notifier);

    useEffect(
      () {
        Future.microtask(
          () async => _pollForQuote(ref, getQuoteNotifier(), quote),
        );
        return getQuoteNotifier().stopPolling;
      },
      [],
    );

    return Scaffold(
      appBar: _buildAppBar(context, ref, quote.value, getQuoteNotifier()),
      body: SafeArea(
        child: order.value == null
            ? quote.value.when(
                data: (q) => q == null
                    ? Container()
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
                                    _buildAmounts(context, q.data),
                                    _buildFeeDetails(context, q.data),
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
                              order,
                            ),
                            title:
                                '${Loc.of(context).pay} ${PaymentFeeDetails.calculateTotalAmount(q.data)} ${q.data.payin.currencyCode}',
                          ),
                        ],
                      ),
                loading: () => LoadingMessage(
                  message: Loc.of(context).gettingYourQuote,
                ),
                error: (error, _) => ErrorMessage(
                  message: error.toString(),
                  onRetry: () => _pollForQuote(ref, getQuoteNotifier(), quote),
                ),
              )
            : order.value!.when(
                data: (_) => ConfirmationMessage(
                  message: Loc.of(context).orderConfirmed,
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
              ),
      ),
    );
  }

  AppBar _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Quote?> quote,
    TbdexQuoteNotifier quoteNotifier,
  ) =>
      AppBar(
        leading: quote.isLoading
            ? IconButton(
                onPressed: () async => showDialog(
                  context: context,
                  builder: (dialogContext) => ExitDialog(
                    title: Loc.of(context)
                        .stoptxnType(paymentState.transactionType.name),
                    description: Loc.of(context).ifYouExitNow,
                    onExit: () async {
                      quoteNotifier.stopPolling();
                      await ref
                          .read(tbdexServiceProvider)
                          .submitClose(
                            ref.read(didProvider),
                            paymentState.selectedPfi,
                            paymentState.exchangeId,
                          )
                          .then(
                            (_) =>
                                Navigator.of(dialogContext).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (dialogContext) => const App(),
                              ),
                              (route) => false,
                            ),
                          );
                    },
                    onStay: () async => Navigator.pop(context),
                  ),
                ),
                icon: const Icon(Icons.close),
              )
            : null,
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

  Future<void> _pollForQuote(
    WidgetRef ref,
    TbdexQuoteNotifier quoteNotifier,
    ValueNotifier<AsyncValue<Quote?>> state,
  ) async {
    state.value = const AsyncLoading();

    try {
      await quoteNotifier
          .startPolling(paymentState.selectedPfi, paymentState.exchangeId)
          ?.then((quote) {
        if (quote != null) {
          state.value = AsyncData(quote);
          quoteNotifier.stopPolling();
        }
      });
    } on Exception catch (e) {
      state.value = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> _submitOrder(
    BuildContext context,
    WidgetRef ref,
    PaymentState paymentState,
    ValueNotifier<AsyncValue<Order>?> state,
  ) async {
    state.value = const AsyncLoading();

    try {
      await ref
          .read(tbdexServiceProvider)
          .submitOrder(
            ref.read(didProvider),
            paymentState.selectedPfi,
            paymentState.exchangeId,
          )
          .then((order) => state.value = AsyncData(order));
    } on Exception catch (e) {
      state.value = AsyncError(e, StackTrace.current);
    }
  }
}
