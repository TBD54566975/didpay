import 'package:flutter/material.dart';
import 'package:flutter_starter/features/pfis/pfis_page.dart';
import 'package:flutter_starter/features/forms/SchemaForms.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:flutter_starter/shared/grid.dart';

class OnboardingWelcomePage extends StatelessWidget {
  const OnboardingWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: Grid.lg),
            Text(
              Loc.of(context).welcomeToDIDPay,
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Grid.xxl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Grid.side),
              child: Text(
                Loc.of(context).toSendMoney,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Grid.side),
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
            const SizedBox(height: Grid.md), // Add some spacing
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Grid.side),
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const FormsPage(), // Replace with your desired page
                      fullscreenDialog: true,
                    ),
                  );
                },
                child: Text('Test Schemas'), // Your custom text
              ),
            ),
            const SizedBox(height: Grid.lg), // Optional spacing at the bottom
          ],
        ),
      ),
    );
  }
}
