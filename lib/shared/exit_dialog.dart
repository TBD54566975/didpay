import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ExitDialog extends HookWidget {
  final String title;
  final String description;
  final Future<void> Function() onExit;
  final Future<void> Function() onStay;

  const ExitDialog({
    required this.title,
    required this.description,
    required this.onExit,
    required this.onStay,
    super.key,
  });

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Center(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        titlePadding: const EdgeInsets.only(top: Grid.xl),
        content: Text(
          description,
          textAlign: TextAlign.center,
        ),
        contentPadding:
            const EdgeInsets.fromLTRB(Grid.lg, Grid.xs, Grid.lg, Grid.xl),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                height: 1,
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withOpacity(0.1),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(Grid.sm),
                          ),
                        ),
                      ),
                      onPressed: () async => onStay(),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: Grid.sm),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withOpacity(0.1),
                            ),
                          ),
                        ),
                        child: Text(
                          Loc.of(context).stay,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(Grid.sm),
                          ),
                        ),
                      ),
                      onPressed: () async => onExit(),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: Grid.sm),
                        child: Text(
                          Loc.of(context).exit,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
        actionsPadding: EdgeInsets.zero,
      );
}
