import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/success_page.dart';

class SendDidPage extends HookWidget {
  final String sendAmount;
  const SendDidPage({super.key, required this.sendAmount});

  @override
  Widget build(BuildContext context) {
    final sendDid = useState<String>('');

    return Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text(
                '\$$sendAmount',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              Text(
                Loc.of(context).accountBalance,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              )
            ],
          ),
          scrolledUnderElevation: 0,
        ),
        body: SafeArea(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Grid.side),
                    child: Column(
                      children: [
                        Column(children: [
                          const SizedBox(height: Grid.lg),
                          GestureDetector(
                            child: Row(
                              children: [
                                const Icon(Icons.qr_code_scanner,
                                    size: Grid.sm),
                                const SizedBox(width: Grid.xs),
                                Expanded(
                                  child: Text(
                                    Loc.of(context).scanQrCode,
                                    softWrap: true,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ]),
                        const SizedBox(height: Grid.lg),
                        Row(
                          children: [
                            Text(Loc.of(context).to,
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(width: Grid.xs),
                            Expanded(
                              child: TextField(
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                      labelText: Loc.of(context).didTag),
                                  enableSuggestions: false,
                                  autocorrect: false,
                                  onChanged: (value) => sendDid.value = value),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Grid.side),
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SuccessPage(
                        text: Loc.of(context).yourPaymentWasSent,
                      ),
                    ),
                  );
                },
                child: Text('${Loc.of(context).pay} \$$sendAmount'),
              ),
            ),
          ]),
        ));
  }
}
