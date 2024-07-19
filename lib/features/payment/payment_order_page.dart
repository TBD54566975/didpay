import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/confirmation_message.dart';
import 'package:didpay/shared/error_message.dart';

import 'package:didpay/shared/loading_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

class PaymentOrderPage extends HookConsumerWidget {
  final PaymentState paymentState;

  const PaymentOrderPage({
    required this.paymentState,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = useState<AsyncValue<Order>>(const AsyncLoading());

    useEffect(
      () {
        Future.microtask(
          () async => _submitOrder(context, ref, paymentState, order),
        );
        return;
      },
      [],
    );

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: order.value.when(
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

  Future<void> _submitOrder(
    BuildContext context,
    WidgetRef ref,
    PaymentState paymentState,
    ValueNotifier<AsyncValue<Order>?> state,
  ) async {
    state.value = const AsyncLoading();

    try {
      final order = await ref.read(tbdexServiceProvider).submitOrder(
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
