import 'package:flutter/material.dart';
import 'package:flutter_starter/features/payments/payment_method.dart';
import 'package:flutter_starter/features/payments/search_payment_methods_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

final _paymentMethods = [
  PaymentMethod(
    kind: 'BANK_ACCESS BANK',
    requiredPaymentDetails: bankSchema,
    fee: '9.0',
  ),
  PaymentMethod(
    kind: 'MOMO_MTN',
    requiredPaymentDetails: momoSchema,
  ),
  PaymentMethod(
    kind: 'WALLET_BTC ADDRESS',
    requiredPaymentDetails: walletSchema,
    fee: '5.0',
  ),
];

void main() {
  group('SearchPaymentMethodsPage', () {
    testWidgets('should show search field', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: SearchPaymentMethodsPage(
            selectedPaymentMethod:
                ValueNotifier<PaymentMethod>(_paymentMethods.first),
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
          child: SearchPaymentMethodsPage(
            selectedPaymentMethod:
                ValueNotifier<PaymentMethod>(_paymentMethods.first),
            paymentMethods: _paymentMethods,
          ),
        ),
      );

      expect(find.byType(ListTile), findsExactly(3));
      expect(find.widgetWithText(ListTile, 'ACCESS BANK'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'MTN'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'BTC ADDRESS'), findsOneWidget);
    });

    testWidgets('should show a payment method after valid search',
        (tester) async {
      final selectedPaymentMethod = ValueNotifier<PaymentMethod>(
        _paymentMethods.first,
      );

      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: SearchPaymentMethodsPage(
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
      final selectedPaymentMethod = ValueNotifier<PaymentMethod>(
        _paymentMethods.first,
      );

      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: SearchPaymentMethodsPage(
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
