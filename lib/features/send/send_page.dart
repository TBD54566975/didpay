import 'package:didpay/features/currency/payin.dart';
import 'package:didpay/features/send/send.dart';
import 'package:didpay/features/send/send_did_page.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/number_pad.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SendPage extends HookWidget {
  const SendPage({super.key});

  @override
  Widget build(BuildContext context) {
    final amount = useState('0');
    final keyPress = useState(PayinKeyPress(0, ''));

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Send(
                    amount: amount,
                    keyPress: keyPress,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Grid.xs),
              child: NumberPad(
                onKeyPressed: (key) => keyPress.value =
                    PayinKeyPress(keyPress.value.count + 1, key),
              ),
            ),
            _buildSendButton(context, amount.value),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton(BuildContext context, String amount) {
    final disabled = double.tryParse(amount) == 0;

    void onPressed() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SendDidPage(sendAmount: amount),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Grid.side),
      child: FilledButton(
        onPressed: disabled ? null : onPressed ,
        child: Text(Loc.of(context).send),
      ),
    );
  }
}
