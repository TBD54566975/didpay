import 'package:flutter/material.dart';
import 'dart:convert';


class JsonSchemaForm extends StatefulWidget {
  final String jsonSchemaString;
  final void Function(Map<String, String>) onSubmit;

  JsonSchemaForm({Key? key, required this.jsonSchemaString, required this.onSubmit}) : super(key: key);

  @override
  DynamicJsonFormState createState() => DynamicJsonFormState();
}

class DynamicJsonFormState extends State<JsonSchemaForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {};

  @override
  Widget build(BuildContext context) {
    final jsonSchema = json.decode(widget.jsonSchemaString);
    List<Widget> formFields = [];
    jsonSchema['properties']?.forEach((key, value) {
      formFields.add(TextFormField(
        decoration: InputDecoration(
          labelText: value['title'] ?? key,
          hintText: value['description'],
        ),
        validator: (value) => validateField(key, value, jsonSchema),
        onSaved: (value) => _formData[key] = value ?? '',
      ));
    });
    

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ...formFields,
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  widget.onSubmit(_formData); // Call the callback function with form data
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  String? validateField(String key, String? value, Map<String, dynamic> jsonSchema) {
    if (jsonSchema['required']?.contains(key) && (value == null || value.isEmpty)) {
      return 'This field cannot be empty';
    }

    if (value != null && value.isNotEmpty) {
      var minLength = jsonSchema['properties'][key]['minLength'] as int?;
      var maxLength = jsonSchema['properties'][key]['maxLength'] as int?;
      var pattern = jsonSchema['properties'][key]['pattern'] as String?;

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