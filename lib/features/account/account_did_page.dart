import 'dart:math';

import 'package:didpay/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AccountDidPage extends HookConsumerWidget {
  const AccountDidPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final did = ref.watch(didProvider);

    const maxSize = 250.0;
    final screenSize = MediaQuery.of(context).size;
    final qrSize = min(screenSize.width * 0.5, maxSize);

    return Scaffold(
      appBar: AppBar(title: Text(Loc.of(context).myDid)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Grid.side),
        child: Column(
          children: [
            const SizedBox(height: Grid.md),
            QrImageView(
              data: did.uri,
              size: qrSize,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              dataModuleStyle: QrDataModuleStyle(
                color: Theme.of(context).colorScheme.onBackground,
                dataModuleShape: QrDataModuleShape.square,
              ),
            ),
            const SizedBox(height: Grid.xxl),
            ListTile(
              title: Text(did.uri),
              trailing: const Icon(Icons.content_copy),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                Clipboard.setData(ClipboardData(text: did.uri));
                final snackBar = SnackBar(
                  content: Text(
                    Loc.of(context).copiedDid,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                );

                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
            ),
          ],
        ),
      ),
    );
  }
}
