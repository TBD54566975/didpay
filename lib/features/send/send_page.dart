import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_starter/features/send/send_did_page.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:flutter_starter/shared/number_pad.dart';
import 'package:flutter_starter/shared/theme/grid.dart';
import 'package:flutter_starter/shared/animations/invalid_number_pad_input_animation.dart';
import 'package:flutter_starter/shared/utils/number_pad_input_validation_util.dart';

class SendPage extends HookWidget {
  const SendPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sendAmount = useState<String>('0');
    final isValidKeyPress = useState<bool>(true);

    return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      child: InvalidNumberPadInputAnimation(
                          textValue: '\$${sendAmount.value}',
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          shouldAnimate: !isValidKeyPress.value)),
                  const SizedBox(height: Grid.lg),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Grid.xs),
              child: NumberPad(
                onKeyPressed: (key) {
                  isValidKeyPress.value = true;
                  isValidKeyPress.value =
                      NumberPadInputValidationUtil.validateKeyPress(
                          sendAmount.value, key);

                  if (isValidKeyPress.value) {
                    sendAmount.value = (sendAmount.value == '0')
                        ? key == '.'
                            ? key.padLeft(2, '0')
                            : key
                        : sendAmount.value + key;
                  }
                },
                onDeletePressed: () {
                  isValidKeyPress.value = true;
                  isValidKeyPress.value =
                      NumberPadInputValidationUtil.validateDeletePress(
                          sendAmount.value);

                  if (isValidKeyPress.value) {
                    sendAmount.value = (sendAmount.value.length > 1)
                        ? sendAmount.value
                            .substring(0, sendAmount.value.length - 1)
                        : '0';
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Grid.side),
              child: FilledButton(
                onPressed: () {
                  isValidKeyPress.value = true;
                  if (num.parse(sendAmount.value) < 0.01) {
                    isValidKeyPress.value = false;
                    return;
                  }
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        SendDidPage(sendAmount: sendAmount.value),
                  ));
                },
                child: Text(Loc.of(context).send),
              ),
            ),
          ]),
        ));
  }
}
