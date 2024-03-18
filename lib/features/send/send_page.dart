import 'package:didpay/features/currency/currency.dart';
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
    // TODO(ethan-tbd): pass in the account balance
    const accountBalance = '0';

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.titleMedium,
                  children: [
                    TextSpan(text: Loc.of(context).availableBalance),
                    TextSpan(
                      text: '$accountBalance ${CurrencyCode.usdc}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Grid.side),
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          SendDidPage(sendAmount: amount.value),
                    ),
                  );
                },
                child: Text(Loc.of(context).send),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
