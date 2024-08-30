import 'package:didpay/features/payment/payment_details_state.dart';
import 'package:didpay/features/payment/payment_method.dart';
import 'package:didpay/features/payment/payment_selection_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data.dart';
import '../../helpers/widget_helpers.dart';

void main() {
  final schema = TestData.paymentDetailsSchema();
  final paymentMethods = [
    PaymentMethod(
      kind: 'BANK_ACCESS BANK',
      name: 'Access Bank',
      schema: schema.toJson(),
      fee: '9.0',
    ),
    PaymentMethod(
      kind: 'MOMO_MTN',
      name: 'MTN',
      schema: schema.toJson(),
    ),
  ];

  final paymentTypes = [
    PaymentMethod(
      type: 'Bank',
      kind: 'BANK_ACCESS BANK',
    ),
    PaymentMethod(
      type: 'Mobile money',
      kind: 'MOMO_MTN',
    ),
    PaymentMethod(
      type: 'Wallet',
      kind: 'BTC_WALLET',
    ),
  ];

  group('PaymentSelectionPage - Payment Methods', () {
    Widget paymentSelectionPageTestWidget() => WidgetHelpers.testableWidget(
          child: PaymentSelectionPage(
            availableMethods: paymentMethods,
            state: ValueNotifier(
              PaymentDetailsState(
                paymentCurrency: '',
                selectedPaymentMethod: paymentMethods.first,
              ),
            ),
          ),
        );

    testWidgets('should show search field for methods', (tester) async {
      await tester.pumpWidget(paymentSelectionPageTestWidget());

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('should show payment method list', (tester) async {
      await tester.pumpWidget(paymentSelectionPageTestWidget());

      expect(find.byType(ListTile), findsExactly(2));
      expect(find.widgetWithText(ListTile, 'Access Bank'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'MTN'), findsOneWidget);
    });

    testWidgets('should show a payment method after valid search',
        (tester) async {
      await tester.pumpWidget(paymentSelectionPageTestWidget());

      await tester.enterText(find.byType(TextFormField), 'MTN');
      await tester.pump();

      expect(find.byType(ListTile), findsExactly(1));
      expect(find.widgetWithText(ListTile, 'MTN'), findsOneWidget);
    });

    testWidgets('should show no payment methods after invalid search',
        (tester) async {
      await tester.pumpWidget(paymentSelectionPageTestWidget());

      await tester.enterText(find.byType(TextFormField), 'invalid');
      await tester.pump();

      expect(find.byType(ListTile), findsNothing);
    });
  });

  group('PaymentSelectionPage - Payment Types', () {
    Widget paymentSelectionPageTestWidget() => WidgetHelpers.testableWidget(
          child: PaymentSelectionPage(
            state: ValueNotifier(
              PaymentDetailsState(paymentMethods: paymentTypes),
            ),
            isSelectingMethod: false,
          ),
        );

    testWidgets('should show search field for types', (tester) async {
      await tester.pumpWidget(paymentSelectionPageTestWidget());

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('should show payment type list', (tester) async {
      await tester.pumpWidget(paymentSelectionPageTestWidget());

      expect(find.byType(ListTile), findsExactly(3));
      expect(find.widgetWithText(ListTile, 'Bank'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Mobile money'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Wallet'), findsOneWidget);
    });

    testWidgets('should show a payment type after valid search',
        (tester) async {
      await tester.pumpWidget(paymentSelectionPageTestWidget());

      await tester.enterText(find.byType(TextFormField), 'Bank');
      await tester.pump();

      expect(find.byType(ListTile), findsExactly(1));
      expect(find.widgetWithText(ListTile, 'Bank'), findsOneWidget);
    });

    testWidgets('should show no payment types after invalid search',
        (tester) async {
      await tester.pumpWidget(paymentSelectionPageTestWidget());

      await tester.enterText(find.byType(TextFormField), 'invalid');
      await tester.pump();

      expect(find.byType(ListTile), findsNothing);
    });
  });
}
