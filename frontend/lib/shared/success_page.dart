import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_starter/features/app/app_tabs.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:flutter_starter/shared/grid.dart';

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
                    (Route<dynamic> route) => false,
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
