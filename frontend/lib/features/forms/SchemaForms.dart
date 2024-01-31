import 'package:flutter/material.dart';
import 'package:flutter_starter/shared/schema_form.dart';

//
// This showcases how to build a form with a onSubmit handler that is rendered based on the schema automatically.
//

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
        child: JsonSchemaForm(
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



