import 'dart:math';

import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
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
      appBar: AppBar(),
      body: Column(
        children: [
          _buildQrCode(context, did.uri, qrSize),
          _buildDid(context, did.uri),
        ],
      ),
    );
  }

  Widget _buildQrCode(BuildContext context, String data, double size) =>
      Padding(
        padding: const EdgeInsets.only(top: Grid.xs),
        child: QrImageView(
          data: data,
          size: size,
          eyeStyle: QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          dataModuleStyle: QrDataModuleStyle(
            color: Theme.of(context).colorScheme.onBackground,
            dataModuleShape: QrDataModuleShape.square,
          ),
        ),
      );

  Widget _buildDid(BuildContext context, String did) => Padding(
        padding: const EdgeInsets.only(top: Grid.xxl),
        child: ListTile(
          title: Text(did),
          trailing: const Icon(Icons.content_copy),
          onTap: () {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();

            Clipboard.setData(ClipboardData(text: did));
            final snackBar = SnackBar(
              content: Text(
                Loc.of(context).copiedDid,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
              ),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            );

            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
        ),
      );
}
