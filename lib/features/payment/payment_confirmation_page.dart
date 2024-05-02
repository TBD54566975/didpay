import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/pending_page.dart';
import 'package:didpay/shared/success_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PaymentConfirmationPage extends HookWidget {
  const PaymentConfirmationPage({super.key});

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
            ? PendingPage(text: Loc.of(context).sendingPayment)
            : SuccessPage(text: Loc.of(context).yourPaymentWasSent),
      ),
    );
  }

  // TODO(ethan-tbd): replace with call to pfi, https://github.com/TBD54566975/didpay/issues/125
  Future<void> sendPayment(ValueNotifier<String?> response) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    response.value = 'success';
  }
}
