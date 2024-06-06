import 'package:didpay/features/countries/countries_page.dart';
import 'package:didpay/features/send/send_details_page.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/next_button.dart';
import 'package:didpay/shared/number/number_display.dart';
import 'package:didpay/shared/number/number_key_press.dart';
import 'package:didpay/shared/number/number_pad.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SendPage extends HookWidget {
  const SendPage({super.key});

  @override
  Widget build(BuildContext context) {
    final amount = useState('0');
    final keyPress = useState(NumberKeyPress(0, ''));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.language, size: Grid.md),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CountriesPage(),
              ),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: Grid.side),
                        child: NumberDisplay(
                          currencyCode: 'USDC',
                          currencyWidget: _buildCurrency(context),
                          amount: amount,
                          keyPress: keyPress,
                          textStyle: const TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Grid.xs),
              child: NumberPad(
                onKeyPressed: (key) => keyPress.value =
                    NumberKeyPress(keyPress.value.count + 1, key),
              ),
            ),
            NextButton(
              onPressed: double.tryParse(amount.value) == 0
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              SendDetailsPage(sendAmount: amount.value),
                        ),
                      ),
              title: Loc.of(context).send,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrency(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: Grid.xxs),
        child: Text(
          'USDC',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      );
}
