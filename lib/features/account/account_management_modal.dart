import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/vcs/vcs_notifier.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AccountManagementModal {
  static Future<dynamic> show(
    BuildContext context,
    WidgetRef ref, {
    Pfi? pfi,
    String? credential,
  }) =>
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
                        pfi != null ? pfi.did : credential!,
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
                    pfi != null
                        ? Loc.of(context).removePfi
                        : Loc.of(context).removeCredential,
                    style: TextStyle(color: Theme.of(context).colorScheme.error)
                        .copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () async {
                  pfi != null
                      ? await ref
                          .read(pfisProvider.notifier)
                          .remove(pfi)
                          .then((_) => Navigator.pop(context))
                      : await ref
                          .read(vcsProvider.notifier)
                          .remove(credential!)
                          .then((_) => Navigator.pop(context));
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
