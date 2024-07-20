import 'package:didpay/features/payment/payment_review_page.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/tbdex/tbdex_quote_notifier.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/error_message.dart';
import 'package:didpay/shared/loading_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

class PaymentQuoteWidget extends HookWidget {
  final PaymentState paymentState;
  final ValueNotifier<AsyncValue<Quote?>> quote;
  final Widget detailsPage;
  final WidgetRef ref;

  const PaymentQuoteWidget({
    required this.paymentState,
    required this.quote,
    required this.detailsPage,
    required this.ref,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    TbdexQuoteNotifier getQuoteNotifier() => ref.read(quoteProvider.notifier);

    useEffect(
      () {
        Future.microtask(() async {
          if (context.mounted) {
            await _pollForQuote(context, ref, getQuoteNotifier(), quote);
          }
        });
        return getQuoteNotifier().stopPolling;
      },
      [],
    );

    return quote.value.when(
      data: (q) => q == null ? Container() : detailsPage,
      loading: () => LoadingMessage(
        message: Loc.of(context).gettingYourQuote,
      ),
      error: (error, _) => ErrorMessage(
        message: error.toString(),
        onRetry: () => _pollForQuote(context, ref, getQuoteNotifier(), quote),
      ),
    );
  }

  Future<void> _pollForQuote(
    BuildContext context,
    WidgetRef ref,
    TbdexQuoteNotifier quoteNotifier,
    ValueNotifier<AsyncValue<Quote?>> state,
  ) async {
    state.value = const AsyncLoading();

    try {
      final quote = await quoteNotifier.startPolling(
        paymentState.paymentAmountState?.pfiDid ?? '',
        paymentState.paymentDetailsState?.exchangeId ?? '',
      );

      if (context.mounted && quote != null) {
        quoteNotifier.stopPolling();

        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentReviewPage(
              paymentState: paymentState.copyWith(
                quote: quote,
              ),
            ),
          ),
        );

        if (context.mounted) {
          state.value = AsyncData(quote);
        }
      }
    } on Exception catch (e) {
      if (context.mounted) {
        state.value = AsyncError(e, StackTrace.current);
      }
    }
  }
}
