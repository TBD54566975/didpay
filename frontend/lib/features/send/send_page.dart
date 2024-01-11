import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:flutter_starter/shared/number_pad.dart';

class SendPage extends HookWidget {
  const SendPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sendAmount = useState<String>('\$0');

    return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    sendAmount.value,
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: NumberPad(
                onKeyPressed: (key) {
                  sendAmount.value = (sendAmount.value == '\$0')
                      ? '\$$key'
                      : '${sendAmount.value}$key';
                },
                onDeletePressed: () {
                  sendAmount.value = (sendAmount.value.length > 2)
                      ? sendAmount.value
                          .substring(0, sendAmount.value.length - 1)
                      : '\$0';
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: FilledButton(
                onPressed: () {},
                child: Text(Loc.of(context).send),
              ),
            ),
          ]),
        ));
  }
}
