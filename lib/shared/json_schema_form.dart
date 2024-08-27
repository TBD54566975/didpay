import 'dart:convert';

import 'package:didpay/features/dap/dap_state.dart';
import 'package:didpay/features/payment/payment_details_state.dart';
import 'package:didpay/shared/next_button.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/utils/text_input_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class JsonSchemaForm extends HookWidget {
  final PaymentDetailsState state;
  final Future<void> Function(Map<String, String>) onSubmit;
  final DapState? dapState;

  final _formKey = GlobalKey<FormState>();

  JsonSchemaForm({
    required this.state,
    required this.onSubmit,
    this.dapState,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final formState = useState<Map<String, _FormFieldStateData>>({});

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

    useEffect(
      () {
        formState.value.forEach((key, fieldState) {
          fieldState.controller.dispose();
        });

        formState.value.clear();

        if (properties != null) {
          properties.forEach((key, value) {
            final valueMap = value as Map<String, dynamic>;
            final pattern = valueMap['pattern'] as String?;

            final formatter = TextInputUtil.getMaskFormatter(pattern);

            final dapPrefillText = (key == 'chain'
                    ? dapState?.protocol
                    : dapState?.paymentAddress) ??
                '';

            final initialText = state.formData?[key] ?? dapPrefillText;
            final controller = TextEditingController(text: initialText);

            final focusNode = FocusNode();

            controller.addListener(() {
              formState.value = {
                ...formState.value,
                key: _FormFieldStateData(
                  formData: controller.text,
                  controller: controller,
                  formatter: formatter,
                  focusNode: focusNode,
                ),
              };
            });

            formState.value[key] = _FormFieldStateData(
              formData: initialText,
              controller: controller,
              formatter: formatter,
              focusNode: focusNode,
            );
          });
        }

        return null;
      },
      [state.selectedPaymentMethod?.schema],
    );

    var formFields = <Widget>[];
    properties?.forEach(
      (key, value) {
        final valueMap = value as Map<String, dynamic>;
        final fieldState = formState.value[key];

        if (fieldState == null) return;

        formFields.add(
          TextFormField(
            controller: fieldState.controller,
            focusNode: fieldState.focusNode,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputUtil.getKeyboardType(valueMap['pattern']),
            decoration: InputDecoration(
              labelText: valueMap['title'] ?? key,
              hintText: fieldState.formatter.getMask() ?? '',
            ),
            inputFormatters: [fieldState.formatter],
            textInputAction: TextInputAction.next,
            validator: (value) => _validateField(
              key,
              value,
              jsonSchema,
            ),
            onSaved: (data) => formState.value = {
              ...formState.value,
              key: _FormFieldStateData(
                formData: data ?? '',
                controller: fieldState.controller,
                formatter: fieldState.formatter,
                focusNode: fieldState.focusNode,
              ),
            },
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
                : () {
                    final data = formState.value
                        .map((key, value) => MapEntry(key, value.formData));
                    onPressed(data);
                  },
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
                : () => onPressed({}),
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

class _FormFieldStateData {
  String formData;
  TextEditingController controller;
  MaskTextInputFormatter formatter;
  FocusNode focusNode;

  _FormFieldStateData({
    required this.formData,
    required this.controller,
    required this.formatter,
    required this.focusNode,
  });
}
