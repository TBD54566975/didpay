import 'package:flutter/material.dart';
import 'package:flutter_starter/features/app/app_tabs.dart';
import 'package:flutter_starter/features/onboarding/onboarding_welcome_page.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:flutter_starter/shared/theme/theme.dart';

class App extends StatelessWidget {
  final bool onboarding;
  const App({required this.onboarding, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DIDPay',
      theme: lightTheme(context),
      darkTheme: darkTheme(context),
      home: onboarding ? const OnboardingWelcomePage() : const AppTabs(),
      localizationsDelegates: Loc.localizationsDelegates,
      supportedLocales: const [
        Locale('en', ''),
      ],
    );
  }
}
