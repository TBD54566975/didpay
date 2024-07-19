import 'dart:convert';

import 'package:didpay/features/payment/payment_details_state.dart';
import 'package:didpay/shared/next_button.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/utils/text_input_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class JsonSchemaForm extends HookWidget {
  final PaymentDetailsState state;
  final void Function(Map<String, String>) onSubmit;

  final _formKey = GlobalKey<FormState>();
  final Map<String, String> formData = {};

  JsonSchemaForm({
    required this.state,
    required this.onSubmit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    void onPressed(Map<String, String> data) {
      if (state.selectedPaymentMethod?.schema == null) {
        onSubmit(data);
      } else {
        if (_formKey.currentState != null &&
            (_formKey.currentState?.validate() ?? false)) {
          _formKey.currentState?.save();
          onSubmit(data);
        }
      }
    }

    if (state.selectedPaymentMethod?.schema == null) {
      return _buildEmptyForm(onPressed);
    }

    final jsonSchema = json.decode(state.selectedPaymentMethod?.schema ?? '')
        as Map<String, dynamic>;
    final properties = jsonSchema['properties'] as Map<String, dynamic>?;

    var formFields = <Widget>[];
    properties?.forEach(
      (key, value) {
        final focusNode = useFocusNode();
        final valueMap = value as Map<String, dynamic>;
        final formatter = TextInputUtil.getMaskFormatter(valueMap['pattern']);

        formFields.add(
          TextFormField(
            initialValue: state.formData?[key],
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
            validator: (value) => _validateField(
              key,
              value,
              jsonSchema,
            ),
            onSaved: (value) => formData[key] = value ?? '',
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
          NextButton(
            onPressed: state.selectedPaymentMethod == null
                ? null
                : () => onPressed(formData),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyForm(Function(Map<String, String>) onPressed) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          NextButton(
            onPressed: state.selectedPaymentMethod == null
                ? null
                : () => onPressed(formData),
          ),
        ],
      );

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
