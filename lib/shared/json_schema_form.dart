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
    final jsonSchema = json.decode(schema) as Map<String, dynamic>;
    final properties = jsonSchema['properties'] as Map<String, dynamic>?;

    var formFields = <Widget>[];
    properties?.forEach(
      (key, value) {
        final focusNode = useFocusNode();
        final valueMap = value as Map<String, dynamic>;

        final formatter = TextInputUtil.getMaskFormatter(valueMap['pattern']);

        formFields.add(
          TextFormField(
            focusNode: focusNode,
            onTapOutside: (_) => focusNode.unfocus(),
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputUtil.getKeyboardType(valueMap['pattern']),
            decoration: InputDecoration(
              labelText: valueMap['title'] ?? key,
              hintText: formatter.getMask(),
            ),
            inputFormatters: [formatter],
            textInputAction: TextInputAction.next,
            validator: (_) => _validateField(
              key,
              TextInputUtil.formatNumericText(
                formatter.getMaskedText(),
              ),
              jsonSchema,
            ),
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
    final requiredFields = jsonSchema['required'] as List<dynamic>?;
    if ((requiredFields?.contains(key) ?? false) &&
        (value == null || value.isEmpty)) {
      return 'This field cannot be empty';
    }

    if (value != null && value.isNotEmpty) {
      // Cast the nested maps to `Map<String, dynamic>` to ensure type safety
      final properties = jsonSchema['properties'] as Map<String, dynamic>?;
      final fieldProperties = properties?[key] as Map<String, dynamic>?;

      final minLength = fieldProperties?['minLength'] as int?;
      final maxLength = fieldProperties?['maxLength'] as int?;
      final pattern = fieldProperties?['pattern'] as String?;

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
