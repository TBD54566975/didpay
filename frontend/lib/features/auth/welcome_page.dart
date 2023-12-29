import 'package:flutter/material.dart';
import 'package:flutter_starter/features/auth/auth_did_page.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Loc.of(context).appName)),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  Loc.of(context).toSendMoney,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                      child: Text(Loc.of(context).getStarted),
                      onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const AuthDidPage(),
                            ),
                          )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
