import 'package:flutter/material.dart';
import 'dart:convert';


// example schema: 
    String jsonSchema = r'''
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "type": "object",
  "properties": {
    "accountNumber": {
      "type": "string",
      "description": "Mobile Money account number of the Recipient",
      "title": "Phone Number",
      "minLength": 12,
      "maxLength": 13,
      "pattern": "^\\+2332[0-9]{8}$"
    },
    "reason": {
      "title": "Reason for sending",
      "description": "To abide by the travel rules and financial reporting requirements, the reason for sending money",
      "type": "string"
    },
    "accountHolderName": {
      "type": "string",
      "title": "Account Holder Name",
      "description": "Name of the account holder as it appears on the Mobile Money account",
      "pattern": "^[A-Za-zs'-]+$",
      "maxLength": 32
    }
  },
  "required": [
    "accountNumber",
    "accountHolderName",
    "reason"
  ],
  "additionalProperties": false
}    
    ''';



class FormsPage extends StatelessWidget {
  const FormsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Forms Page')),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: DynamicJsonForm(
          jsonSchemaString: jsonSchema,
          onSubmit: (formData) {
            // Handle form data submission logic here
            print(formData);
          },
        ),
      ),
    );
  }
}

class DynamicJsonForm extends StatefulWidget {
  final String jsonSchemaString;
  final void Function(Map<String, String>) onSubmit;

  DynamicJsonForm({Key? key, required this.jsonSchemaString, required this.onSubmit}) : super(key: key);

  @override
  _DynamicJsonFormState createState() => _DynamicJsonFormState();
}

class _DynamicJsonFormState extends State<DynamicJsonForm> {
  final _formKey = GlobalKey<FormState>();
  Map<String, String> _formData = {};

  @override
  Widget build(BuildContext context) {
    final jsonSchema = json.decode(widget.jsonSchemaString);
    List<Widget> formFields = [];

    if (jsonSchema['properties'] != null) {
      jsonSchema['properties'].forEach((key, value) {
        formFields.add(TextFormField(
          decoration: InputDecoration(
            labelText: value['title'] ?? key,
            hintText: value['description'],
          ),
          validator: (value) => validateField(key, value, jsonSchema),
          onSaved: (value) => _formData[key] = value ?? '',
        ));
      });
    }

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