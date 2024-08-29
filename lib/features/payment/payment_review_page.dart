import 'package:auto_size_text/auto_size_text.dart';
import 'package:decimal/decimal.dart';
import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/payment/payment_confirmation_page.dart';
import 'package:didpay/features/payment/payment_fee_details.dart';
import 'package:didpay/features/payment/payment_link_webview_page.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/tbdex/tbdex_order_instructions_notifier.dart';
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
    final orderInstructions = useState<AsyncValue<OrderInstructions?>?>(null);

    final quote = paymentState.paymentDetailsState?.quote?.data;
    final isAwaiting = orderInstructions.value?.isLoading ?? false;

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
        appBar: isAwaiting ? null : AppBar(),
        body: SafeArea(
          child: orderInstructions.value != null
              ? orderInstructions.value!.when(
                  data: (_) =>
                      _buildPage(context, ref, quote, orderInstructions),
                  loading: () => LoadingMessage(
                    message: Loc.of(context).sendingYourOrder,
                  ),
                  error: (error, _) => ErrorMessage(
                    message: error.toString(),
                    onRetry: () => _submitOrder(
                      context,
                      ref,
                      paymentState,
                      orderInstructions,
                    ),
                  ),
                )
              : _buildPage(context, ref, quote, orderInstructions),
        ),
      ),
    );
  }

  Widget _buildPage(
    BuildContext context,
    WidgetRef ref,
    QuoteData? quote,
    ValueNotifier<AsyncValue<OrderInstructions?>?> state,
  ) =>
      Column(
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
                    _buildAmounts(
                      context,
                      quote,
                    ),
                    _buildFeeDetails(
                      context,
                      quote,
                    ),
                    _buildPaymentDetails(context),
                  ],
                ),
              ),
            ),
          ),
          NextButton(
            onPressed: () => (state.value?.hasValue ?? false)
                ? _onInstructionsFetched(
                    context,
                    state.value!.asData!.value,
                  )
                : _submitOrder(
                    context,
                    ref,
                    paymentState,
                    state,
                  ),
            title:
                '${Loc.of(context).pay} ${PaymentFeeDetails.calculateTotalAmount(quote)} ${quote?.payin.currencyCode}',
          ),
        ],
      );

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
    ValueNotifier<AsyncValue<OrderInstructions?>?> state,
  ) async {
    state.value = const AsyncLoading();

    try {
      await ref.read(tbdexServiceProvider).sendOrder(
            ref.read(didProvider),
            paymentState.paymentAmountState?.pfiDid ?? '',
            paymentState.paymentDetailsState?.exchangeId ?? '',
          );

      if (context.mounted) {
        await _pollForInstructions(context, ref, state);
      }
    } on Exception catch (e) {
      state.value = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> _pollForInstructions(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<AsyncValue<OrderInstructions?>?> state,
  ) async {
    final instructionsNotifier = ref.read(orderInstructionsProvider.notifier);

    try {
      final fetchedInstructions = await instructionsNotifier.startPolling(
        paymentState.paymentAmountState?.pfiDid ?? '',
        paymentState.paymentDetailsState?.exchangeId ?? '',
      );

      if (context.mounted) {
        state.value = AsyncData(fetchedInstructions);
        instructionsNotifier.stopPolling();

        if (fetchedInstructions != null && state.value != null) {
          await _onInstructionsFetched(context, fetchedInstructions);
        }
      }
    } on Exception catch (e) {
      if (context.mounted) {
        instructionsNotifier.stopPolling();
        state.value = AsyncError(e, StackTrace.current);
      }
    }
  }

  Future<void> _onInstructionsFetched(
    BuildContext context,
    OrderInstructions? instructions,
  ) async {
    final paymentLink = instructions?.data.payin.link;

    if (paymentLink == null) {
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const PaymentConfirmationPage(),
        ),
        (route) => false,
      );
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaymentLinkWebviewPage(
            paymentLink: paymentLink,
          ),
        ),
      );
    }
  }
}
