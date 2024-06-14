import 'package:didpay/features/payment/payment_methods_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbdex/tbdex.dart';

import '../../helpers/test_data.dart';
import '../../helpers/widget_helpers.dart';

void main() {
  final schema = TestData.paymentDetailsSchema();
  final paymentMethods = [
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

  group('PaymentMethodsPage', () {
    Widget paymentMethodsPageTestWidget() => WidgetHelpers.testableWidget(
          child: PaymentMethodsPage(
            paymentCurrency: '',
            selectedPaymentMethod:
                ValueNotifier<PayinMethod>(paymentMethods.first),
            paymentMethods: paymentMethods,
          ),
        );
    testWidgets('should show search field', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: paymentMethodsPageTestWidget()),
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
                ValueNotifier<PayinMethod>(paymentMethods.first),
            paymentMethods: paymentMethods,
          ),
        ),
      );

      expect(find.byType(ListTile), findsExactly(2));
      expect(find.widgetWithText(ListTile, 'Access Bank'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'MTN'), findsOneWidget);
    });

    testWidgets('should show a payment method after valid search',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: paymentMethodsPageTestWidget()),
      );

      await tester.enterText(find.byType(TextFormField), 'MTN');
      await tester.pump();

      expect(find.byType(ListTile), findsExactly(1));
      expect(find.widgetWithText(ListTile, 'MTN'), findsOneWidget);
    });

    testWidgets('should show no payment methods after invalid search',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: paymentMethodsPageTestWidget()),
      );

      await tester.enterText(find.byType(TextFormField), 'invalid');
      await tester.pump();

      expect(find.byType(ListTile), findsNothing);
    });
  });
}
