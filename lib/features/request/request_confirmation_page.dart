import 'package:didpay/shared/success_page.dart';
import 'package:didpay/shared/pending_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:didpay/l10n/app_localizations.dart';

class RequestConfirmationPage extends HookWidget {
  const RequestConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final response = useState<String?>(null);

    useEffect(() {
      sendPayment(response);
      return null;
    }, []);

    return Scaffold(
      body: SafeArea(
        child: response.value == null
            ? PendingPage(text: Loc.of(context).sendingRequest)
            : SuccessPage(text: Loc.of(context).yourRequestWasSent),
      ),
    );
  }

  // TODO: replace with call to pfi
  Future<void> sendPayment(ValueNotifier<String?> response) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    response.value = 'success';
  }
}
