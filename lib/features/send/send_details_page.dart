import 'package:didpay/features/device/device_info_service.dart';
import 'package:didpay/features/did/did_qr.dart';
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

class SendDetailsPage extends HookConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  final String sendAmount;

  SendDetailsPage({required this.sendAmount, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusNode = useFocusNode();
    final isPhysicalDevice = useState(true);
    final errorText = useState<String?>(null);
    final sendResponse = useState<AsyncValue<void>?>(null);

    final recipientDidController = useTextEditingController();

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

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: sendResponse.value == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Header(
                            title: Loc.of(context).enterRecipientDid,
                            subtitle: Loc.of(context).makeSureInfoIsCorrect,
                          ),
                          _buildDidForm(
                            context,
                            recipientDidController,
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
                    Loc.of(context).scanRecipientQrCode,
                    recipientDidController,
                    errorText,
                    isPhysicalDevice: isPhysicalDevice.value,
                  ),
                  NextButton(
                    onPressed: () {
                      if ((_formKey.currentState?.validate() ?? false) &&
                          errorText.value == null) {
                        _sendPayment(sendResponse);
                      }
                    },
                    title: Loc.of(context).sendAmountUsdc(sendAmount),
                  ),
                ],
              )
            : sendResponse.value!.when(
                data: (_) =>
                    AsyncDataWidget(text: Loc.of(context).yourPaymentWasSent),
                loading: () =>
                    AsyncLoadingWidget(text: Loc.of(context).sendingPayment),
                error: (error, _) => AsyncErrorWidget(
                  text: error.toString(),
                  onRetry: () => Navigator.pop(context),
                ),
              ),
      ),
    );
  }

  Widget _buildDidForm(
    BuildContext context,
    TextEditingController recipientDidController,
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
                  controller: recipientDidController,
                  onTap: () => errorText.value = null,
                  onTapOutside: (_) async {
                    if (recipientDidController.text.isNotEmpty) {
                      errorText.value = !(await DidResolver.resolve(
                        recipientDidController.text,
                      ))
                              .hasError()
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

  Future<void> _sendPayment(ValueNotifier<AsyncValue<void>?> state) async {
    state.value = const AsyncLoading();
    await Future.delayed(const Duration(milliseconds: 1000));
    state.value = const AsyncValue.data(null);
  }
}
