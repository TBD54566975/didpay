import 'package:didpay/features/app/app_tabs.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SuccessPage extends HookWidget {
  final String text;
  const SuccessPage({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: Grid.xl),
                  Text(text, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: Grid.xs),
                  Icon(
                    Icons.check_circle,
                    size: Grid.xl,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Grid.side),
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AppTabs()),
                    (route) => false,
                  );
                },
                child: Text(Loc.of(context).done),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
