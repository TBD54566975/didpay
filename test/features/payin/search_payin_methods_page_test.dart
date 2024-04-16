import 'package:didpay/features/payin/search_payin_methods_page.dart';
import 'package:didpay/features/payment/payment_method.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

final _paymentMethods = [
  PaymentMethod(
    kind: 'BANK_ACCESS BANK',
    name: 'Access Bank',
    requiredPaymentDetails: bankSchema,
    fee: '9.0',
  ),
  PaymentMethod(
    kind: 'MOMO_MTN',
    name: 'MTN',
    requiredPaymentDetails: momoSchema,
  ),
];

void main() {
  group('SearchPayinMethodsPage', () {
    testWidgets('should show search field', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: SearchPayinMethodsPage(
            selectedPayinMethod:
                ValueNotifier<PaymentMethod>(_paymentMethods.first),
            payinMethods: _paymentMethods,
            payinCurrency: '',
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
          child: SearchPayinMethodsPage(
            selectedPayinMethod:
                ValueNotifier<PaymentMethod>(_paymentMethods.first),
            payinMethods: _paymentMethods,
            payinCurrency: '',
          ),
        ),
      );

      expect(find.byType(ListTile), findsExactly(2));
      expect(find.widgetWithText(ListTile, 'Access Bank'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'MTN'), findsOneWidget);
    });

    testWidgets('should show a payment method after valid search',
        (tester) async {
      final selectedPaymentMethod = ValueNotifier<PaymentMethod>(
        _paymentMethods.first,
      );

      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: SearchPayinMethodsPage(
            selectedPayinMethod: selectedPaymentMethod,
            payinMethods: _paymentMethods,
            payinCurrency: '',
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
          child: SearchPayinMethodsPage(
            selectedPayinMethod: selectedPaymentMethod,
            payinMethods: _paymentMethods,
            payinCurrency: '',
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'invalid');
      await tester.pump();

      expect(find.byType(ListTile), findsNothing);
    });
  });
}
