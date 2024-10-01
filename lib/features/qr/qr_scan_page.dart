import 'dart:math';

import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanPage extends HookWidget {
  const QrScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isProcessing = useState(false);
    final controller = useMemoized(MobileScannerController.new);

    const maxSize = 400.0;
    final screenSize = MediaQuery.of(context).size;
    final scanSize = screenSize.width * 0.8;

    final scanWindow = Rect.fromCenter(
      center: Offset(screenSize.width / 2, screenSize.height / 2 - Grid.xxl),
      width: min(scanSize, maxSize),
      height: min(scanSize, maxSize),
    );

    useOnAppLifecycleStateChange(
      (_, current) => current == AppLifecycleState.resumed
          ? controller.start()
          : controller.stop(),
    );

    return SafeArea(
      top: false,
      bottom: false,
      child: Stack(
        children: [
          MobileScanner(
            controller: controller,
            scanWindow: scanWindow,
            onDetect: (barcode) {
              if (isProcessing.value) return;
              isProcessing.value = true;

              Navigator.of(context).pop(
                barcode.barcodes.map((e) => e.rawValue).join(),
              );
            },
            errorBuilder: (context, error, child) => Padding(
              padding: EdgeInsets.only(bottom: scanWindow.height / 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.no_photography,
                    size: Grid.xxl,
                  ),
                  const SizedBox(height: Grid.sm),
                  Center(
                    child: Text(
                      Loc.of(context).cameraUnavailable,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          CustomPaint(painter: _ScannerOverlay(scanWindow)),
        ],
      ),
    );
  }
}

class _ScannerOverlay extends CustomPainter {
  final Rect scanWindow;

  _ScannerOverlay(this.scanWindow);

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.largest);
    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          scanWindow,
          topLeft: const Radius.circular(Grid.radius),
          topRight: const Radius.circular(Grid.radius),
          bottomLeft: const Radius.circular(Grid.radius),
          bottomRight: const Radius.circular(Grid.radius),
        ),
      );

    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final borderRect = RRect.fromRectAndCorners(
      scanWindow,
      topLeft: const Radius.circular(Grid.radius),
      topRight: const Radius.circular(Grid.radius),
      bottomLeft: const Radius.circular(Grid.radius),
      bottomRight: const Radius.circular(Grid.radius),
    );

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = Grid.quarter;

    canvas.drawPath(backgroundWithCutout, backgroundPaint);
    canvas.drawRRect(borderRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
