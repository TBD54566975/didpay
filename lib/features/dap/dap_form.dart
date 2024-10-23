import 'package:dap/dap.dart';
import 'package:didpay/features/dap/dap_qr_tile.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/next_button.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DapForm extends HookConsumerWidget {
  final String buttonTitle;
  final ValueNotifier<String?> dapText;
  final ValueNotifier<AsyncValue<Dap>?> dap;
  final Future<void> Function(Dap, List<MoneyAddress>) onSubmit;

  DapForm({
    required this.buttonTitle,
    required this.dapText,
    required this.dap,
    required this.onSubmit,
    super.key,
  });

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorText = useState<String?>(null);
    final focusNode = useFocusNode();

    final textController = useTextEditingController(text: dapText.value);
    final errorMessage = Loc.of(context).invalidDap;

    useEffect(
      () {
        if (dapText.value != null && dapText.value!.isNotEmpty) {
          focusNode.requestFocus();
        }
        return null;
      },
      [],
    );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: Grid.side),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextFormField(
                          focusNode: focusNode,
                          controller: textController,
                          onTap: () => errorText.value = null,
                          onTapOutside: (_) {
                            if (textController.text.isNotEmpty) {
                              _parseDap(
                                textController.text,
                                errorMessage,
                                errorText,
                              );
                            }

                            focusNode.unfocus();
                          },
                          onFieldSubmitted: (_) => _parseDap(
                            textController.text,
                            errorMessage,
                            errorText,
                          ),
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: InputDecoration(
                            labelText: Loc.of(context).dapHint,
                            errorText: errorText.value,
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? Loc.of(context).thisFieldCannotBeEmpty
                              : null,
                        ),
                      ),
                      const SizedBox(width: Grid.xs),
                      if (dap.value?.isLoading ?? false)
                        const Padding(
                          padding: EdgeInsets.all(Grid.xxs),
                          child: SizedBox.square(
                            dimension: Grid.sm,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          DapQrTile(dapTextController: textController),
          NextButton(
            onPressed: () async {
              final parsedDap = _parseDap(
                textController.text,
                errorMessage,
                errorText,
              );

              dapText.value = textController.text;

              if (errorText.value == null) {
                await _resolveDap(parsedDap);
              }
            },
            title: buttonTitle,
          ),
        ],
      ),
    );
  }

  Dap? _parseDap(
    String inputText,
    String errorMessage,
    ValueNotifier<String?> errorText,
  ) {
    try {
      final parsedDap = Dap.parse(inputText);
      errorText.value = null;
      return parsedDap;
    } on Exception {
      errorText.value = errorMessage;
    }
    return null;
  }

  Future<void> _resolveDap(Dap? parsedDap) async {
    if (parsedDap == null) return;
    try {
      dap.value = const AsyncValue.loading();
      final result = await DapResolver().resolve(parsedDap);

      dap.value = AsyncValue.data(result.dap);
      await onSubmit(result.dap, result.moneyAddresses);
    } on Exception catch (e) {
      dap.value =
          AsyncError('${e.runtimeType}: Invalid DAP', StackTrace.current);
    }
  }
}
