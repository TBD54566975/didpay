import 'package:didpay/features/app/app_tabs.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class App extends HookConsumerWidget {
  const App({super.key});

  // TODO(ethan-tbd): add launch icon

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
        title: 'DIDPay',
        theme: lightTheme(context),
        darkTheme: darkTheme(context),
        home: const AppTabs(),
        localizationsDelegates: Loc.localizationsDelegates,
        supportedLocales: const [
          Locale('en', ''),
        ],
      );
}
