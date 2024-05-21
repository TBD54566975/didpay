import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PfiModal {
  static Future<dynamic> show(
    BuildContext context,
    WidgetRef ref,
    Pfi pfi,
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
                padding: const EdgeInsets.symmetric(vertical: Grid.sm),
                child: Text(
                  pfi.did,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              Divider(
                color: Theme.of(context).colorScheme.outlineVariant,
                thickness: 0.25,
              ),
              ListTile(
                title: Center(
                  child: Text(
                    Loc.of(context).removePfi,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
                onTap: () async {
                  await ref.read(pfisProvider.notifier).remove(pfi);
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
              ),
              Divider(
                color: Theme.of(context).colorScheme.outlineVariant,
                thickness: 0.25,
              ),
              ListTile(
                title: Center(
                  child: Text(
                    Loc.of(context).cancel,
                    style: Theme.of(context).textTheme.bodyLarge,
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
