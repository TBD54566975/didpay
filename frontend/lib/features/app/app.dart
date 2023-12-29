import 'package:flutter/material.dart';
import 'package:flutter_starter/features/auth/welcome_page.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:flutter_starter/shared/theme/theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DIDPay',
      theme: lightTheme(context),
      darkTheme: darkTheme(context),
      home: const WelcomePage(),
      localizationsDelegates: Loc.localizationsDelegates,
      supportedLocales: const [
        Locale('en', ''),
      ],
    );
  }
}
