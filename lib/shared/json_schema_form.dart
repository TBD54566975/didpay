import 'dart:convert';

import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/utils/text_input_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class JsonSchemaForm extends HookWidget {
  final String schema;
  final void Function(Map<String, String>) onSubmit;

  final _formKey = GlobalKey<FormState>();
  final Map<String, String> formData = {};

  JsonSchemaForm({required this.schema, required this.onSubmit, super.key});

  @override
  Widget build(BuildContext context) {
    final jsonSchema = json.decode(schema);

    List<Widget> formFields = [];
    jsonSchema['properties']?.forEach(
      (key, value) {
        final focusNode = useFocusNode();
        final formatter = TextInputUtil.getMaskFormatter(value['pattern']);

        formFields.add(
          TextFormField(
            focusNode: focusNode,
            onTapOutside: (_) => focusNode.unfocus(),
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputUtil.getKeyboardType(value['pattern']),
            decoration: InputDecoration(
              labelText: value['title'] ?? key,
              hintText: formatter.getMask(),
            ),
            inputFormatters: [formatter],
            textInputAction: TextInputAction.next,
            validator: (_) => _validateField(
                key,
                TextInputUtil.formatNumericText(
                  formatter.getMaskedText(),
                ),
                jsonSchema),
            onSaved: (_) => formData[key] = TextInputUtil.formatNumericText(
              formatter.getMaskedText(),
            ),
          ),
        );
      },
    );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Grid.side),
                child: Column(children: formFields),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Grid.side),
            child: FilledButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  onSubmit(formData);
                }
              },
              child: Text(Loc.of(context).next),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateField(
    String key,
    String? value,
    Map<String, dynamic> jsonSchema,
  ) {
    if (jsonSchema['required']?.contains(key) &&
        (value == null || value.isEmpty)) {
      return 'This field cannot be empty';
    }

    if (value != null && value.isNotEmpty) {
      var minLength = jsonSchema['properties'][key]['minLength'] as int?;
      var maxLength = jsonSchema['properties'][key]['maxLength'] as int?;
      var pattern = jsonSchema['properties'][key]['pattern'] as String?;

      if (minLength != null &&
          minLength == maxLength &&
          value.length != minLength) {
        return 'Must be exactly $minLength characters';
      }

      if (minLength != null && value.length < minLength) {
        return 'Minimum length is $minLength characters';
      }

      if (maxLength != null && value.length > maxLength) {
        return 'Maximum length is $maxLength characters';
      }

      if (pattern != null && !RegExp(pattern).hasMatch(value)) {
        return 'Invalid format';
      }
    }

    return null;
  }
}
