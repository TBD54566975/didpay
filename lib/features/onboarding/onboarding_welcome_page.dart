import 'package:flutter/material.dart';
import 'package:didpay/features/pfis/pfis_page.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';

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
            const SizedBox(height: Grid.lg), // Optional spacing at the bottom
          ],
        ),
      ),
    );
  }
}
