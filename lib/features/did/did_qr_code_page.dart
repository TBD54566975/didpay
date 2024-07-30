import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/did/did_storage_service.dart';
import 'package:didpay/features/vcs/vcs_notifier.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/confirm_dialog.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DidQrCodePage extends HookConsumerWidget {
  final String dap;
  const DidQrCodePage({required this.dap, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final did = ref.watch(didProvider);
    final didStorageService = ref.watch(didServiceProvider);

    const maxSize = 400.0;
    final screenSize = MediaQuery.of(context).size;
    final qrSize = min(screenSize.width * 0.8, maxSize);
    final offsetX = (screenSize.width - qrSize) / 2;
    final offsetY = screenSize.height / 2 - qrSize / 2 - Grid.xxl;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: offsetX,
            top: offsetY,
            child: Container(
              width: qrSize,
              height: qrSize,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(Grid.radius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(Grid.sm),
                child: Center(
                  child: buildQrCode(context, did.uri, qrSize - Grid.sm * 2),
                ),
              ),
            ),
          ),
          Positioned(
            left: (screenSize.width - qrSize) / 2,
            top: offsetY + qrSize + Grid.sm,
            width: qrSize,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Grid.sm),
                  // TODO(ethan-tbd): remove portable did copy feature
                  child: ListTile(
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () async {
                        final didJson = await ref
                            .read(didServiceProvider)
                            .getPortableDidJson();
                        await Clipboard.setData(
                          ClipboardData(
                            text: didJson ?? 'Error: portable did not found',
                          ),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Copied portable did',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                              ),
                              shape: ShapeBorder.lerp(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(Grid.xs),
                                ),
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(Grid.xs),
                                ),
                                1,
                              ),
                              margin: const EdgeInsets.symmetric(
                                horizontal: Grid.xl,
                              ),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                              backgroundColor:
                                  Theme.of(context).colorScheme.surface,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                    ),
                    title: Center(
                      child: AutoSizeText(
                        did.uri,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Grid.sm),
                FilledButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmDialog(
                        title: Loc.of(context).areYouSure,
                        description: Loc.of(context)
                            .allOfYourCredentialsWillAlsoBeDeleted,
                        confirmText: Loc.of(context).regenerate,
                        cancelText: Loc.of(context).goBack,
                        onConfirm: () async {
                          final newDid =
                              await didStorageService.regenerateDid();
                          ref.read(didProvider.notifier).state = newDid;

                          await ref.read(vcsProvider.notifier).reset();

                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        onCancel: () async {
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                  child: const Text('Regenerate DID'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQrCode(BuildContext context, String data, double size) =>
      QrImageView(
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
      );
}
