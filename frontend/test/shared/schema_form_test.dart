import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/shared/schema_form.dart';
import '../helpers/widget_helpers.dart';

void main() {
  const String jsonSchemaString = '''
  {
    "properties": {
      "name": {
        "title": "Name",
        "description": "Enter your name",
        "type": "string",
        "minLength": 2,
        "maxLength": 10
      },
      "email": {
        "title": "Email",
        "description": "Enter your email",
        "type": "string",
        "pattern": "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\$"
      }
    },
    "required": ["name", "email"]
  }''';

  group('JsonSchemaForm', () {
    testWidgets('should render form fields based on JSON schema', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: JsonSchemaForm(
            jsonSchemaString: jsonSchemaString,
            onSubmit: (_) {},
          ),
        ),
      );

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('should validate form fields correctly', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: JsonSchemaForm(
            jsonSchemaString: jsonSchemaString,
            onSubmit: (_) {},
          ),
        ),
      );

      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(find.text('This field cannot be empty'), findsNWidgets(2));

      await tester.enterText(find.byType(TextFormField).at(0), 'A');
      await tester.enterText(find.byType(TextFormField).at(1), 'invalid_email');
      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(find.text('Minimum length is 2 characters'), findsOneWidget);
      expect(find.text('Invalid format'), findsOneWidget);
    });

    testWidgets('should call onSubmit with correct data when form is valid', (tester) async {
      Map<String, String>? submittedData;
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: JsonSchemaForm(
            jsonSchemaString: jsonSchemaString,
            onSubmit: (formData) {
              submittedData = formData;
            },
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'John');
      await tester.enterText(find.byType(TextFormField).at(1), 'john@example.com');
      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(submittedData, equals({'name': 'John', 'email': 'john@example.com'}));
    });
  });
}
