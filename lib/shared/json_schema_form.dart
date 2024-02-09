import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_starter/l10n/app_localizations.dart';
import 'package:flutter_starter/shared/theme/grid.dart';

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
    jsonSchema['properties']?.forEach((key, value) {
      formFields.add(TextFormField(
        decoration: InputDecoration(
          labelText: value['title'] ?? key,
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          border: InputBorder.none,
        ),
        validator: (value) => _validateField(key, value, jsonSchema),
        onSaved: (value) => formData[key] = value ?? '',
      ));
    });

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Grid.side,
                ),
                child: Column(
                  children: formFields,
                ),
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
