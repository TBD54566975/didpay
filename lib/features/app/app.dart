import 'package:flutter/material.dart';
import 'package:didpay/features/app/app_tabs.dart';
import 'package:didpay/features/onboarding/welcome_page.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/theme.dart';

class App extends StatelessWidget {
  final bool onboarding;
  const App({required this.onboarding, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DIDPay',
      theme: lightTheme(context),
      darkTheme: darkTheme(context),
      home: onboarding ? const WelcomePage() : const AppTabs(),
      localizationsDelegates: Loc.localizationsDelegates,
      supportedLocales: const [
        Locale('en', ''),
      ],
    );
  }
}
