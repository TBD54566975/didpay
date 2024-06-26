import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DidQrCodePage extends HookConsumerWidget {
  final String dap;
  const DidQrCodePage({required this.dap, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final did = ref.watch(didProvider);

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Grid.sm),
              child: AutoSizeText(
                'Scan to pay $dap',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
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
