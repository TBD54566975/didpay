import 'package:didpay/features/did_qr/did_qr_scan_page.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:web5/web5.dart';

class DidQr {
  static Widget buildScanTile(
    BuildContext context,
    String title,
    TextEditingController didTextController,
    ValueNotifier<String?> errorText, {
    required bool isPhysicalDevice,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: Grid.xxs),
        child: ListTile(
          leading: const Icon(Icons.qr_code),
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => isPhysicalDevice
              ? _scanQrCode(
                  context,
                  didTextController,
                  errorText,
                  Loc.of(context).noDidQrCodeFound,
                )
              : _simulateScanQrCode(
                  context,
                  didTextController,
                  errorText,
                ),
        ),
      );

  static Widget buildQrCode(BuildContext context, String data, double size) =>
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

  static Future<void> _scanQrCode(
    BuildContext context,
    TextEditingController didTextController,
    ValueNotifier<String?> errorText,
    String errorMessage,
  ) async {
    final qrValue = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => const DidQrScanPage()),
    );

    final isValid =
        qrValue != null && !(await DidResolver.resolve(qrValue)).hasError();
    didTextController.text = isValid ? qrValue : '';
    errorText.value = isValid ? null : errorMessage;
  }

  static Future<void> _simulateScanQrCode(
    BuildContext context,
    TextEditingController didTextController,
    ValueNotifier<String?> errorText,
  ) async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(Loc.of(context).simulatedQrCodeScan),
      ),
    );

    final did = await DidDht.create(publish: true);
    didTextController.text = did.uri;
    errorText.value = null;
  }
}
