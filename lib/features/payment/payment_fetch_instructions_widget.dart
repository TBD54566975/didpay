import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/tbdex/tbdex_order_instructions_notifier.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/error_message.dart';
import 'package:didpay/shared/loading_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

class PaymentFetchInstructionsWidget extends HookWidget {
  final PaymentState paymentState;
  final ValueNotifier<AsyncValue<OrderInstructions?>> instructions;
  final ValueNotifier<AsyncValue<Order>?> order;
  final Future<void> Function(BuildContext, OrderInstructions)
      onInstructionsFetched;
  final WidgetRef ref;

  const PaymentFetchInstructionsWidget({
    required this.paymentState,
    required this.instructions,
    required this.order,
    required this.onInstructionsFetched,
    required this.ref,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    TbdexOrderInstructionsNotifier getInstructionsNotifier() =>
        ref.read(orderInstructionsProvider.notifier);

    useEffect(
      () {
        Future.microtask(() async {
          if (context.mounted) {
            await _pollForInstructions(context, ref, getInstructionsNotifier());
          }
        });
        return getInstructionsNotifier().stopPolling;
      },
      [],
    );

    return instructions.value.when(
      data: (q) => Container(),
      loading: () => LoadingMessage(
        message: Loc.of(context).fetchingPaymentInstructions,
      ),
      error: (error, _) => ErrorMessage(
        message: error.toString(),
        onRetry: () =>
            _pollForInstructions(context, ref, getInstructionsNotifier()),
      ),
    );
  }

  Future<void> _pollForInstructions(
    BuildContext context,
    WidgetRef ref,
    TbdexOrderInstructionsNotifier instructionsNotifier,
  ) async {
    instructions.value = const AsyncLoading();

    try {
      final fetchedInstructions = await instructionsNotifier.startPolling(
        paymentState.paymentAmountState?.pfiDid ?? '',
        paymentState.paymentDetailsState?.exchangeId ?? '',
      );

      if (context.mounted && fetchedInstructions != null) {
        instructionsNotifier.stopPolling();

        await onInstructionsFetched(context, fetchedInstructions);

        if (context.mounted) {
          instructions.value = AsyncData(fetchedInstructions);
          order.value = null;
        }
      }
    } on Exception catch (e) {
      if (context.mounted) {
        instructions.value = AsyncError(e, StackTrace.current);
      }
    }
  }
}
