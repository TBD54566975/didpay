import 'package:didpay/features/device/device_info_service.dart';
import 'package:didpay/features/did/did_qr.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/async/async_data_widget.dart';
import 'package:didpay/shared/async/async_error_widget.dart';
import 'package:didpay/shared/async/async_loading_widget.dart';
import 'package:didpay/shared/header.dart';
import 'package:didpay/shared/next_button.dart';
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
    final isPhysicalDevice = useState(true);
    final errorText = useState<String?>(null);
    final pfi = useState<AsyncValue<Pfi>?>(null);

    final pfiDidController = useTextEditingController();

    final focusNode = useFocusNode();

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
        child: pfi.value != null
            ? pfi.value!.when(
                data: (_) => AsyncDataWidget(text: Loc.of(context).pfiAdded),
                loading: () =>
                    AsyncLoadingWidget(text: Loc.of(context).addingPfi),
                error: (error, _) => AsyncErrorWidget(
                  text: error.toString(),
                  onRetry: () => _addPfi(ref, pfiDidController.text, pfi),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Header(
                            title: Loc.of(context).addAPfi,
                            subtitle: Loc.of(context).makeSureInfoIsCorrect,
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
                  NextButton(
                    onPressed: () {
                      if ((_formKey.currentState?.validate() ?? false) &&
                          errorText.value == null) {
                        _addPfi(ref, pfiDidController.text, pfi);
                      }
                    },
                    title: Loc.of(context).add,
                  ),
                ],
              ),
      ),
    );
  }

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
                      try {
                        final result =
                            await DidResolver.resolve(pfiDidController.text);
                        errorText.value =
                            result.hasError() ? errorMessage : null;
                      } on Exception catch (_) {
                        errorText.value = errorMessage;
                      }
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

  Future<void> _addPfi(
    WidgetRef ref,
    String did,
    ValueNotifier<AsyncValue<Pfi>?> state,
  ) async {
    state.value = const AsyncLoading();

    try {
      await ref
          .read(pfisProvider.notifier)
          .add(did)
          .then((pfi) => state.value = AsyncData(pfi));
    } on Exception catch (e) {
      state.value = AsyncError(e, StackTrace.current);
    }
  }
}
