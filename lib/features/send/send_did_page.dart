import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/send/scan_qr_page.dart';
import 'package:didpay/features/send/send_confirmation_page.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/services/service_providers.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web5/web5.dart';

class SendDidPage extends HookConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  final String sendAmount;

  SendDidPage({required this.sendAmount, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final did = ref.watch(didProvider);

    final focusNode = useFocusNode();
    final isPhysicalDevice = useState(true);
    final errorText = useState<String?>(null);
    final controller = useTextEditingController();

    useEffect(
      () {
        Future.microtask(() async {
          isPhysicalDevice.value =
              await ref.read(deviceInfoServiceProvider).isPhysicalDevice();
        });

        return null;
      },
      [],
    );

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
                    _buildScanQr(
                      context,
                      controller,
                      errorText,
                      isPhysicalDevice,
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
            _buildSendButton(context, did.uri, errorText.value),
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
  ) =>
      Padding(
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
                    errorText: errorText.value,
                  ),
                  validator: (value) => value == null
                      ? Loc.of(context).thisFieldCannotBeEmpty
                      : null,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildScanQr(
    BuildContext context,
    TextEditingController controller,
    ValueNotifier<String?> errorText,
    ValueNotifier<bool> isPhysicalDevice,
    String did,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: Grid.xxs),
        child: ListTile(
          leading: const Icon(Icons.qr_code),
          title: Text(
            Loc.of(context).scanQrCode,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => isPhysicalDevice.value
              ? _scanQrCode(
                  context,
                  controller,
                  errorText,
                  Loc.of(context).noDidQrCodeFound,
                )
              : _simulateScanQrCode(
                  context,
                  controller,
                  did,
                ),
        ),
      );

  Widget _buildSendButton(
    BuildContext context,
    String did,
    String? errorText,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Grid.side),
        child: FilledButton(
          onPressed: () {
            if ((_formKey.currentState?.validate() ?? false) &&
                errorText == null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SendConfirmationPage(
                    did: did,
                    amount: sendAmount,
                  ),
                ),
              );
            }
          },
          child: Text(Loc.of(context).sendAmountUsdc(sendAmount)),
        ),
      );

  Future<bool> _isValidDid(String did) async {
    final result = await DidResolver.resolve(did);
    return !result.hasError();
  }

  Future<void> _scanQrCode(
    BuildContext context,
    TextEditingController controller,
    ValueNotifier<String?> errorText,
    String errorMessage,
  ) async {
    // ignore: use_build_context_synchronously
    final qrValue = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => const ScanQrPage()),
    );

    final isValid = qrValue != null && await _isValidDid(qrValue);
    controller.text = isValid ? qrValue : '';
    errorText.value = isValid ? null : errorMessage;
  }

  void _simulateScanQrCode(
    BuildContext context,
    TextEditingController controller,
    String did,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(Loc.of(context).simulatedQrCodeScan),
      ),
    );
    controller.text = did;
  }
}
