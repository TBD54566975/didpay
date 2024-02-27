import 'package:didpay/features/onboarding/country_page.dart';
import 'package:flutter/material.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class WelcomePage extends HookWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(
              context,
              Loc.of(context).welcomeToDIDPay,
              Loc.of(context).interactWithPfis,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Grid.side),
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CountryPage(),
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

  Widget _buildHeader(BuildContext context, String title, String subtitle) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: Grid.side, vertical: Grid.xs),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: Grid.xs),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
