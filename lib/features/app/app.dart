import 'package:didpay/features/app/app_tabs.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/theme.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
}
