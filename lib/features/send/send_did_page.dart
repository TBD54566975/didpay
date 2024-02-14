import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/send/scan_qr_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/success_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web5_flutter/web5_flutter.dart';

class SendDidPage extends HookConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  final String sendAmount;

  SendDidPage({super.key, required this.sendAmount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final did = ref.watch(didProvider);

    final focusNode = useFocusNode();
    final errorText = useState<String?>(null);
    final controller = useTextEditingController();

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildScanQrTile(
                      context,
                      controller,
                      errorText,
                      did.uri,
                    ),
                    _buildForm(
                      context,
                      controller,
                      focusNode,
                      errorText,
                      Loc.of(context).invalidDid,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Grid.side),
              child: FilledButton(
                onPressed: () {
                  if ((_formKey.currentState?.validate() ?? false) &&
                      errorText.value == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SuccessPage(
                          text: Loc.of(context).yourPaymentWasSent,
                        ),
                      ),
                    );
                  }
                },
                child: Text('${Loc.of(context).pay} \$$sendAmount'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
    ValueNotifier<String?> errorText,
    String errorMessage,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Grid.side),
      child: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: Grid.xs),
              child: Text(
                Loc.of(context).to,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            Expanded(
              child: TextFormField(
                focusNode: focusNode,
                controller: controller,
                onTap: () => errorText.value = null,
                onTapOutside: (_) async {
                  if (controller.text.isNotEmpty) {
                    errorText.value = await _isValidDid(controller.text)
                        ? null
                        : errorMessage;
                  }
                  focusNode.unfocus();
                },
                maxLines: null,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                    labelText: Loc.of(context).didPrefix,
                    errorText: errorText.value),
                validator: (value) => value == null
                    ? Loc.of(context).thisFieldCannotBeEmpty
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanQrTile(
    BuildContext context,
    TextEditingController controller,
    ValueNotifier<String?> errorText,
    String did,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Grid.xxs),
      child: ListTile(
        leading: const Icon(Icons.qr_code),
        title: Text(
          Loc.of(context).scanQrCode,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _scanQrCode(context, controller, errorText,
            Loc.of(context).noDidQrCodeFound, did),
      ),
    );
  }

  Future<bool> _isPhysicalDevice() async {
    final deviceInfo = DeviceInfoPlugin();
    return Platform.isIOS
        ? (await deviceInfo.iosInfo).isPhysicalDevice
        : Platform.isAndroid
            ? (await deviceInfo.androidInfo).isPhysicalDevice
            : false;
  }

  Future<bool> _isValidDid(String did) async {
    final result = await DidJwk.resolve(did);
    return !result.hasError();
  }

  void _scanQrCode(
    BuildContext context,
    TextEditingController controller,
    ValueNotifier<String?> errorText,
    String errorMessage,
    String did,
  ) async {
    if (await _isPhysicalDevice()) {
      // ignore: use_build_context_synchronously
      final qrValue = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (context) => const ScanQrPage()),
      );

      final isValid = qrValue != null && await _isValidDid(qrValue);
      controller.text = isValid ? qrValue : '';
      errorText.value = isValid ? null : errorMessage;
      return;
    }

    final snackBar = SnackBar(
      content: Text(
        // ignore: use_build_context_synchronously
        Loc.of(context).simulatedQrCodeScan,
      ),
    );
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    controller.text = did;
  }
}
