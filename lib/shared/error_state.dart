import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ErrorState extends HookConsumerWidget {
  final String text;
  final VoidCallback onRetry;

  const ErrorState({
    required this.text,
    required this.onRetry,
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Grid.side),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, Loc.of(context).errorFound, text),
            Expanded(child: Container()),
            FilledButton(
              onPressed: onRetry,
              child: Text(Loc.of(context).tapToRetry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title, String subtitle) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: Grid.xs),
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
