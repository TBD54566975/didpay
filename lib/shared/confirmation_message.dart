import 'package:didpay/features/app/app.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/next_button.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ConfirmationMessage extends HookWidget {
  final String message;
  const ConfirmationMessage({required this.message, super.key});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: Grid.xl),
                Text(message, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: Grid.xs),
                Icon(
                  Icons.check_circle,
                  size: Grid.xl,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
          NextButton(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const App()),
              (route) => false,
            ),
            title: Loc.of(context).done,
          ),
        ],
      );
}
