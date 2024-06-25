import 'package:didpay/features/device/device_info_service.dart';
import 'package:didpay/features/did/did_qr_tabs.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web5/web5.dart';

class DapQrTile extends HookConsumerWidget {
  final TextEditingController dapTextController;
  final ValueNotifier<String?>? errorText;

  const DapQrTile({
    required this.dapTextController,
    this.errorText,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPhysicalDevice = useState(true);

    useEffect(
      () {
        Future.microtask(
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
          Loc.of(context).dontKnowTheirDap,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => isPhysicalDevice.value
            ? _scanQrCode(
                context,
                dapTextController,
                errorText,
                Loc.of(context).noDapQrCodeFound,
              )
            : _simulateScanQrCode(
                context,
                dapTextController,
                errorText,
              ),
      ),
    );
  }

  Future<void> _scanQrCode(
    BuildContext context,
    TextEditingController dapTextController,
    ValueNotifier<String?>? errorText,
    String errorMessage,
  ) async {
    final qrValue = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => DidQrTabs(dap: Loc.of(context).placeholderDap),
      ),
    );

    final isValid = qrValue != null &&
        await DidResolver.resolve(qrValue).then((result) => !result.hasError());
    dapTextController.text = isValid ? qrValue : '';
    errorText?.value = isValid ? null : errorMessage;
  }

  Future<void> _simulateScanQrCode(
    BuildContext context,
    TextEditingController didTextController,
    ValueNotifier<String?>? errorText,
  ) async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(Loc.of(context).simulatedQrCodeScan),
      ),
    );

    didTextController.text = '@moegrammer/didpay.me';
    errorText?.value = null;
  }
}
