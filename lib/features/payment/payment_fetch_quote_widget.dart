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

class PaymentFetchQuoteWidget extends HookWidget {
  final PaymentState paymentState;
  final ValueNotifier<AsyncValue<Quote?>> quote;
  final ValueNotifier<AsyncValue<Rfq>?> rfq;
  final WidgetRef ref;

  const PaymentFetchQuoteWidget({
    required this.paymentState,
    required this.quote,
    required this.rfq,
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
            await _pollForQuote(context, ref, getQuoteNotifier());
          }
        });
        return getQuoteNotifier().stopPolling;
      },
      [],
    );

    return quote.value.when(
      data: (q) => Container(),
      loading: () => LoadingMessage(
        message: Loc.of(context).gettingYourQuote,
      ),
      error: (error, _) => ErrorMessage(
        message: error.toString(),
        onRetry: () => _pollForQuote(context, ref, getQuoteNotifier()),
      ),
    );
  }

  Future<void> _pollForQuote(
    BuildContext context,
    WidgetRef ref,
    TbdexQuoteNotifier quoteNotifier,
  ) async {
    quote.value = const AsyncLoading();

    try {
      final fetchedQuote = await quoteNotifier.startPolling(
        paymentState.paymentAmountState?.pfiDid ?? '',
        paymentState.paymentDetailsState?.exchangeId ?? '',
      );

      if (context.mounted && fetchedQuote != null) {
        quoteNotifier.stopPolling();

        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentReviewPage(
              paymentState: paymentState.copyWith(
                quote: fetchedQuote,
              ),
            ),
          ),
        );

        if (context.mounted) {
          quote.value = const AsyncData(null);
          rfq.value = null;
        }
      }
    } on Exception catch (e) {
      if (context.mounted) {
        quote.value = AsyncError(e, StackTrace.current);
      }
    }
  }
}
