import 'package:didpay/features/send/scan_qr_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/success_page.dart';

class SendDidPage extends HookWidget {
  final _formKey = GlobalKey<FormState>();

  final String sendAmount;
  SendDidPage({super.key, required this.sendAmount});

  @override
  Widget build(BuildContext context) {
    final focusNode = useFocusNode();
    final controller = useTextEditingController();

    return Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: Grid.xxs),
                    _buildScanQrTile(context, controller),
                    const SizedBox(height: Grid.xxs),
                    _buildForm(context, focusNode, controller),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Grid.side),
              child: FilledButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SuccessPage(
                            text: Loc.of(context).yourPaymentWasSent),
                      ),
                    );
                  }
                },
                child: Text('${Loc.of(context).pay} \$$sendAmount'),
              ),
            ),
          ]),
        ));
  }

  Widget _buildForm(BuildContext context, FocusNode focusNode,
      TextEditingController controller) {
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
                    onTapOutside: (event) => focusNode.unfocus(),
                    maxLines: null,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: Loc.of(context).didPrefix,
                    ),
                    validator: (value) {
                      if (value == null ||
                          !value.startsWith(Loc.of(context).didPrefix)) {
                        return Loc.of(context).invalidDid;
                      }
                      return null;
                    }),
              ),
            ],
          )),
    );
  }

  Widget _buildScanQrTile(
      BuildContext context, TextEditingController controller) {
    return ListTile(
      leading: const Icon(Icons.qr_code),
      title: Text(
        Loc.of(context).scanQrCode,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: Grid.side),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _scanQrCode(context, controller, Loc.of(context).didPrefix),
    );
  }

  void _scanQrCode(
    BuildContext context,
    TextEditingController controller,
    String didPrefix,
  ) async {
    final scannedDid = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => const ScanQrPage()),
    );
    if (scannedDid != null) {
      controller.text = scannedDid.startsWith(didPrefix) ? scannedDid : '';
      _formKey.currentState?.validate();
    }
  }
}
