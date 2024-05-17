import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/async_loading_widget.dart';
import 'package:didpay/shared/success_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SendConfirmationPage extends HookWidget {
  // TODO(ethan-tbd): replace with DAP, https://github.com/TBD54566975/didpay/issues/135
  final String did;
  final String amount;

  const SendConfirmationPage({
    required this.did,
    required this.amount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final response = useState<String?>(null);

    useEffect(
      () {
        sendPayment(response);
        return null;
      },
      [],
    );

    return Scaffold(
      body: SafeArea(
        child: response.value == null
            ? AsyncLoadingWidget(text: Loc.of(context).sendingPayment)
            : SuccessState(text: Loc.of(context).yourPaymentWasSent),
      ),
    );
  }

  // TODO(ethan-tbd): replace with call to pfi, https://github.com/TBD54566975/didpay/issues/135
  Future<void> sendPayment(ValueNotifier<String?> response) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    response.value = 'success';
  }
}
