import 'package:flutter/material.dart';
import 'package:flutter_starter/features/pfis/pfis_page.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';

class OnboardingWelcomePage extends StatelessWidget {
  const OnboardingWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Text(
              Loc.of(context).welcomeToDIDPay,
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                Loc.of(context).toSendMoney,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PfisPage(),
                      fullscreenDialog: true,
                    ),
                  );
                },
                child: Text(Loc.of(context).getStarted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
