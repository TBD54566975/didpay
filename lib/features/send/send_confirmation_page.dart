import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/pending_page.dart';
import 'package:didpay/shared/success_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

// TODO(ethan-tbd): make HookConsumerWidget after pfi is implemented
class SendConfirmationPage extends HookWidget {
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
            ? PendingPage(text: Loc.of(context).sendingPayment)
            : SuccessPage(text: Loc.of(context).yourPaymentWasSent),
      ),
    );
  }

  // TODO(ethan-tbd): replace with call to pfi
  Future<void> sendPayment(ValueNotifier<String?> response) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    response.value = 'success';
  }
}
