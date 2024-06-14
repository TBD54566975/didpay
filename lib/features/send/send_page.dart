import 'package:didpay/features/account/account_balance_notifier.dart';
import 'package:didpay/features/countries/countries_page.dart';
import 'package:didpay/features/feature_flags/feature_flag.dart';
import 'package:didpay/features/feature_flags/feature_flags_notifier.dart';
import 'package:didpay/features/feature_flags/lucid/lucid_offerings_page.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/send/send_details_page.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/next_button.dart';
import 'package:didpay/shared/number/number_display.dart';
import 'package:didpay/shared/number/number_key_press.dart';
import 'package:didpay/shared/number/number_pad.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SendPage extends HookConsumerWidget {
  const SendPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pfis = ref.watch(pfisProvider);
    final accountBalance = ref.watch(accountBalanceProvider(pfis));
    final featureFlags = ref.watch(featureFlagsProvider);

    final amount = useState('0');
    final keyPress = useState(NumberKeyPress(0, ''));

    final sendCurrency = accountBalance.asData?.value?.currencyCode ?? '';

    return Scaffold(
      appBar: _buildAppBar(context, featureFlags),
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
                          currencyCode: sendCurrency,
                          currencyWidget: _buildCurrency(context, sendCurrency),
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

  AppBar _buildAppBar(BuildContext context, List<FeatureFlag> featureFlags) =>
      AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: Grid.xxs),
          child: IconButton(
            icon: const Icon(Icons.language, size: Grid.lg),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CountriesPage(),
                ),
              );
            },
          ),
        ),
        actions: featureFlags.any(
          (flag) => flag.name == Loc.of(context).lucidMode && flag.isEnabled,
        )
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: Grid.xxs),
                  child: IconButton(
                    icon: const Icon(Icons.deblur, size: Grid.lg),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LucidOfferingsPage(),
                      ),
                    ),
                  ),
                ),
              ]
            : null,
      );

  Widget _buildCurrency(BuildContext context, String sendCurrency) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: Grid.xxs),
        child: Text(
          sendCurrency,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      );
}
