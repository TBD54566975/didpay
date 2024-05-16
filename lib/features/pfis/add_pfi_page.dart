import 'package:didpay/features/device/device_info_service.dart';
import 'package:didpay/features/did_qr/did_qr.dart';
import 'package:didpay/features/pfis/add_pfi_confirmation_page.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web5/web5.dart';

class AddPfiPage extends HookConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  AddPfiPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusNode = useFocusNode();
    final isPhysicalDevice = useState(true);
    final errorText = useState<String?>(null);
    final pfiDidController = useTextEditingController();

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
                    _buildHeader(
                      context,
                      Loc.of(context).addAPfi,
                      Loc.of(context).makeSureInfoIsCorrect,
                    ),
                    _buildDidForm(
                      context,
                      pfiDidController,
                      focusNode,
                      errorText,
                      Loc.of(context).invalidDid,
                    ),
                  ],
                ),
              ),
            ),
            DidQr.buildScanTile(
              context,
              Loc.of(context).scanPfiQrCode,
              pfiDidController,
              errorText,
              isPhysicalDevice: isPhysicalDevice.value,
            ),
            _buildAddButton(
              context,
              ref,
              pfiDidController,
              errorText.value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title, String subtitle) =>
      Padding(
        padding: const EdgeInsets.symmetric(
          vertical: Grid.xs,
          horizontal: Grid.side,
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: Grid.xs),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );

  Widget _buildDidForm(
    BuildContext context,
    TextEditingController pfiDidController,
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
                  controller: pfiDidController,
                  onTap: () => errorText.value = null,
                  onTapOutside: (_) async {
                    if (pfiDidController.text.isNotEmpty) {
                      errorText.value = await _isValidDid(pfiDidController.text)
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
                  validator: (value) => value == null || value.isEmpty
                      ? Loc.of(context).thisFieldCannotBeEmpty
                      : null,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildAddButton(
    BuildContext context,
    WidgetRef ref,
    TextEditingController pfiDidController,
    String? errorText,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Grid.side),
      child: FilledButton(
        onPressed: () {
          if ((_formKey.currentState?.validate() ?? false) &&
              errorText == null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddPfiConfirmationPage(
                  did: pfiDidController.text,
                ),
              ),
            );
          }
        },
        child: const Text('Add'),
      ),
    );
  }

  static Future<bool> _isValidDid(String did) async {
    try {
      final result = await DidResolver.resolve(did);
      return !result.hasError();
    } on Exception catch (_) {
      return false;
    }
  }
}
