import 'package:didpay/features/did/did_qr_tile.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/next_button.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web5/web5.dart';

class DidForm extends HookConsumerWidget {
  final String buttonTitle;
  final void Function(String) onSubmit;

  DidForm({required this.buttonTitle, required this.onSubmit, super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorText = useState<String?>(null);
    final focusNode = useFocusNode();

    final textController = useTextEditingController();
    final errorMessage = Loc.of(context).invalidDid;

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
                  TextFormField(
                    focusNode: focusNode,
                    controller: textController,
                    onTap: () => errorText.value = null,
                    onTapOutside: (_) async => _updateErrorText(
                      textController.text,
                      errorMessage,
                      errorText,
                    ).then((_) => focusNode.unfocus()),
                    onFieldSubmitted: (_) async => _updateErrorText(
                      textController.text,
                      errorMessage,
                      errorText,
                    ),
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
                ],
              ),
            ),
          ),
          DidQrTile(
            title: Loc.of(context).dontKnowTheirDap,
            didTextController: textController,
            errorText: errorText,
          ),
          NextButton(
            onPressed: () async => _updateErrorText(
              textController.text,
              errorMessage,
              errorText,
            ).then(
              (_) => errorText.value == null
                  ? onSubmit(textController.text)
                  : null,
            ),
            title: buttonTitle,
          ),
        ],
      ),
    );
  }

  Future<void> _updateErrorText(
    String did,
    String errorMessage,
    ValueNotifier<String?> errorText,
  ) async {
    try {
      did.isNotEmpty &&
              await DidResolver.resolve(did)
                  .then((result) => !result.hasError())
          ? errorText.value = null
          : errorText.value = errorMessage;
    } on Exception {
      errorText.value = errorMessage;
    }
  }
}
