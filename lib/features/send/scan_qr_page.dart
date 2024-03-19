import 'dart:math';

import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrPage extends HookWidget {
  const ScanQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isProcessing = useState(false);
    final controller = useMemoized(MobileScannerController.new);

    useOnAppLifecycleStateChange(
      (_, current) => current == AppLifecycleState.resumed
          ? controller.start()
          : controller.stop(),
    );

    const maxSize = 400.0;
    final screenSize = MediaQuery.of(context).size;
    final scanSize = screenSize.width * 0.8;

    final scanWindow = Rect.fromCenter(
      center: screenSize.center(Offset.zero),
      width: min(scanSize, maxSize),
      height: min(scanSize, maxSize),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: controller.toggleTorch,
          ),
        ],
      ),
      body: SafeArea(
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
            ),
            CustomPaint(painter: _ScannerOverlay(scanWindow)),
          ],
        ),
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
      ..color = Colors.black.withOpacity(0.5)
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
