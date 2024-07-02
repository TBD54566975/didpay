import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';

class ModalRemoveItem {
  static Future<dynamic> show(
    BuildContext context,
    String title,
    String removeText,
    Future<void> Function() onRemove,
  ) =>
      showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: Grid.sm,
                  horizontal: Grid.md,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  mainAxisAlignment: MainAxisAlignment.center,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: AutoSizeText(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withOpacity(0.1),
              ),
              ListTile(
                title: Center(
                  child: Text(
                    removeText,
                    style: TextStyle(color: Theme.of(context).colorScheme.error)
                        .copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () async {
                  await onRemove();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
              Divider(
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withOpacity(0.1),
              ),
              ListTile(
                title: Center(
                  child: Text(
                    Loc.of(context).cancel,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      );
}
