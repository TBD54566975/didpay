import 'package:didpay/features/did/did_qr_tile.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/next_button.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DidForm extends HookConsumerWidget {
  final String buttonTitle;
  final Future<void> Function(String) onSubmit;

  DidForm({required this.buttonTitle, required this.onSubmit, super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusNode = useFocusNode();

    final textController = useTextEditingController();

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
                    onTapOutside: (_) => focusNode.unfocus(),
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: Loc.of(context).didHint,
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? Loc.of(context).thisFieldCannotBeEmpty
                        : null,
                  ),
                ],
              ),
            ),
          ),
          DidQrTile(didTextController: textController),
          NextButton(
            onPressed: () async => onSubmit(textController.text),
            title: buttonTitle,
          ),
        ],
      ),
    );
  }
}
