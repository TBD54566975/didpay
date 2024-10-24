import 'package:didpay/features/device/device_info_service.dart';
import 'package:didpay/features/qr/qr_tabs.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/snackbar/snackbar_service.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web5/web5.dart';

class DidQrTile extends HookConsumerWidget {
  final TextEditingController didTextController;

  const DidQrTile({
    required this.didTextController,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPhysicalDevice = useState(true);
    final snackbarService = SnackbarService();

    useEffect(
      () {
        Future.delayed(
          Duration.zero,
          () async => isPhysicalDevice.value =
              await ref.read(deviceInfoServiceProvider).isPhysicalDevice(),
        );
        return null;
      },
      [],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Grid.xxs),
      child: ListTile(
        leading: const Icon(Icons.qr_code),
        title: Text(
          Loc.of(context).dontKnowTheirDid,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => isPhysicalDevice.value
            ? _scanQrCode(
                context,
                didTextController,
              )
            : _simulateScanQrCode(
                context,
                didTextController,
                snackbarService,
              ),
      ),
    );
  }

  Future<void> _scanQrCode(
    BuildContext context,
    TextEditingController didTextController,
  ) async {
    final qrValue = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => QrTabs(dap: Loc.of(context).placeholderDap),
      ),
    );

    didTextController.text = qrValue ?? '';
  }

  Future<void> _simulateScanQrCode(
    BuildContext context,
    TextEditingController didTextController,
    SnackbarService snackbarService,
  ) async {
    snackbarService.showSnackBar(context, Loc.of(context).simulatedQrCodeScan);

    final did = await DidDht.create(publish: true);
    didTextController.text = did.uri;
  }
}
