import 'dart:convert';

import 'package:didpay/features/payment/payment_methods_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_schema/json_schema.dart';
import 'package:tbdex/tbdex.dart';

import '../../helpers/widget_helpers.dart';

final schema = JsonSchema.create(
  jsonDecode(r'''
        {
          "$schema": "http://json-schema.org/draft-07/schema#",
          "type": "object",
          "properties": {
            "cardNumber": {
              "type": "string",
              "title": "Card number",
              "description": "The 16-digit debit card number",
              "minLength": 16,
              "maxLength": 16
            },
            "expiryDate": {
              "type": "string",
              "description": "The expiry date of the card in MM/YY format",
              "pattern": "^(0[1-9]|1[0-2])\\/([0-9]{2})$"
            },
            "cardHolderName": {
              "type": "string",
              "description": "Name of the cardholder as it appears on the card"
            },
            "cvv": {
              "type": "string",
              "description": "The 3-digit CVV code",
              "minLength": 3,
              "maxLength": 3
            }
          },
          "required": ["cardNumber", "expiryDate", "cardHolderName", "cvv"],
          "additionalProperties": false
        }
    '''),
);

final _paymentMethods = [
  PayinMethod(
    kind: 'BANK_ACCESS BANK',
    name: 'Access Bank',
    requiredPaymentDetails: schema,
    fee: '9.0',
  ),
  PayinMethod(
    kind: 'MOMO_MTN',
    name: 'MTN',
    requiredPaymentDetails: schema,
  ),
];

void main() {
  group('PaymentMethodsPage', () {
    testWidgets('should show search field', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: PaymentMethodsPage(
            paymentCurrency: '',
            selectedPaymentMethod:
                ValueNotifier<PayinMethod>(_paymentMethods.first),
            paymentMethods: _paymentMethods,
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('should show payment method list', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: PaymentMethodsPage(
            paymentCurrency: '',
            selectedPaymentMethod:
                ValueNotifier<PayinMethod>(_paymentMethods.first),
            paymentMethods: _paymentMethods,
          ),
        ),
      );

      expect(find.byType(ListTile), findsExactly(2));
      expect(find.widgetWithText(ListTile, 'Access Bank'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'MTN'), findsOneWidget);
    });

    testWidgets('should show a payment method after valid search',
        (tester) async {
      final selectedPaymentMethod = ValueNotifier<PayinMethod>(
        _paymentMethods.first,
      );

      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: PaymentMethodsPage(
            paymentCurrency: '',
            selectedPaymentMethod: selectedPaymentMethod,
            paymentMethods: _paymentMethods,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'MTN');
      await tester.pump();

      expect(find.byType(ListTile), findsExactly(1));
      expect(find.widgetWithText(ListTile, 'MTN'), findsOneWidget);
    });

    testWidgets('should show no payment methods after invalid search',
        (tester) async {
      final selectedPaymentMethod = ValueNotifier<PayinMethod>(
        _paymentMethods.first,
      );

      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: PaymentMethodsPage(
            paymentCurrency: '',
            selectedPaymentMethod: selectedPaymentMethod,
            paymentMethods: _paymentMethods,
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'invalid');
      await tester.pump();

      expect(find.byType(ListTile), findsNothing);
    });
  });
}
