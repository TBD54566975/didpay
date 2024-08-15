import 'package:didpay/features/payment/payment_details_state.dart';
import 'package:didpay/features/payment/payment_method.dart';
import 'package:didpay/shared/json_schema_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/widget_helpers.dart';

void main() {
  const jsonSchemaString = r'''
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
        "pattern": "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$"
      }
    },
    "required": ["name", "email"]
  }''';

  group('JsonSchemaForm', () {
    Widget jsonSchemaFormTestWidget({
      Future<void> Function(Map<String, String>)? onSubmit,
    }) =>
        WidgetHelpers.testableWidget(
          child: JsonSchemaForm(
            state: PaymentDetailsState(
              selectedPaymentMethod:
                  PaymentMethod(kind: '', schema: jsonSchemaString),
            ),
            onSubmit: onSubmit ?? (_) async {},
          ),
        );
    testWidgets('should render form fields based on JSON schema',
        (tester) async {
      await tester.pumpWidget(jsonSchemaFormTestWidget());

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('should validate form fields correctly', (tester) async {
      await tester.pumpWidget(jsonSchemaFormTestWidget());

      await tester.tap(find.text('Next'));
      await tester.pump();
      expect(find.text('This field cannot be empty'), findsNWidgets(2));

      await tester.enterText(find.byType(TextFormField).at(0), 'A');
      await tester.enterText(find.byType(TextFormField).at(1), 'invalid_email');
      await tester.tap(find.text('Next'));
      await tester.pump();

      expect(find.text('Minimum length is 2 characters'), findsOneWidget);
      expect(find.text('Invalid format'), findsOneWidget);
    });

    testWidgets('should call onSubmit with correct data when form is valid',
        (tester) async {
      Map<String, String>? submittedData;

      await tester.pumpWidget(
        jsonSchemaFormTestWidget(
          onSubmit: (formData) async => submittedData = formData,
        ),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'John');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'john@example.com',
      );
      await tester.tap(find.text('Next'));
      await tester.pump();

      expect(
        submittedData,
        equals({'name': 'John', 'email': 'john@example.com'}),
      );
    });
  });
}
