import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
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
      "maxLength": 12,
      "pattern": "^+2332[0-9]{8}$"
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


// this is an example of a widget that renders the json schema
class FormsPage extends StatelessWidget {
  const FormsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the JSON schema string
    return Scaffold(
      appBar: AppBar(title: Text('Forms Page')),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: DynamicJsonForm(jsonSchemaString: jsonSchema),
      ),
    );
  }
}


class DynamicJsonForm extends StatelessWidget {
  final String jsonSchemaString;

  DynamicJsonForm({Key? key, required this.jsonSchemaString}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final jsonSchema = json.decode(jsonSchemaString);
    List<Widget> formFields = [];

    if (jsonSchema['properties'] != null) {
      jsonSchema['properties'].forEach((key, value) {
        formFields.add(FormBuilderTextField(
          name: key,
          decoration: InputDecoration(
            labelText: value['title'] ?? key,
            hintText: value['description'],
          ),
          validator: (value) {
            if (jsonSchema['required']?.contains(key) ?? false && (value == null || value.isEmpty)) {
              return 'This field cannot be empty';
            }
            var minLength = jsonSchema['properties'][key]['minLength'] as int?;
            var maxLength = jsonSchema['properties'][key]['maxLength'] as int?;
            var pattern = jsonSchema['properties'][key]['pattern'] as String?;

            if (value != null && minLength != null && value.length < minLength) {
              return 'Minimum length is $minLength';
            }
            if (value != null && maxLength != null && value.length > maxLength) {
              return 'Maximum length is $maxLength';
            }
            if (value != null && pattern != null && !RegExp(pattern).hasMatch(value)) {
              return 'Invalid format';
            }
            return null;
          },
        ));
      });
    }

    return FormBuilder(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ...formFields,
            ElevatedButton(
              onPressed: () {
                // Implement submission logic
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

