import 'package:didpay/features/did/did_form.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/async/async_data_widget.dart';
import 'package:didpay/shared/async/async_error_widget.dart';
import 'package:didpay/shared/async/async_loading_widget.dart';
import 'package:didpay/shared/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SendDetailsPage extends HookConsumerWidget {
  final String sendAmount;

  const SendDetailsPage({required this.sendAmount, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final send = useState<AsyncValue<void>?>(null);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: send.value != null
            ? send.value!.when(
                data: (_) =>
                    AsyncDataWidget(text: Loc.of(context).yourPaymentWasSent),
                loading: () =>
                    AsyncLoadingWidget(text: Loc.of(context).sendingPayment),
                error: (error, _) => AsyncErrorWidget(
                  text: error.toString(),
                  onRetry: () => _sendPayment(send),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Header(
                    title: Loc.of(context).enterRecipientDid,
                    subtitle: Loc.of(context).makeSureInfoIsCorrect,
                  ),
                  Expanded(
                    child: DidForm(
                      buttonTitle: Loc.of(context).sendAmountUsdc(sendAmount),
                      onSubmit: (did) => _sendPayment(send),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _sendPayment(ValueNotifier<AsyncValue<void>?> state) async {
    state.value = const AsyncLoading();
    await Future.delayed(const Duration(milliseconds: 1000));
    state.value = const AsyncValue.data(null);
  }
}
