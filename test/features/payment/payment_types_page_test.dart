import 'package:didpay/features/payment/payment_details_state.dart';
import 'package:didpay/features/payment/payment_method.dart';
import 'package:didpay/features/payment/payment_types_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  final paymentMethods = [
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

  group('PaymentTypesPage', () {
    Widget paymentTypesPageTestWidget() => WidgetHelpers.testableWidget(
          child: PaymentTypesPage(
            state: ValueNotifier(
              PaymentDetailsState(paymentMethods: paymentMethods),
            ),
          ),
        );

    testWidgets('should show search field', (tester) async {
      await tester.pumpWidget(paymentTypesPageTestWidget());

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('should show payment type list', (tester) async {
      await tester.pumpWidget(paymentTypesPageTestWidget());

      expect(find.byType(ListTile), findsExactly(3));
      expect(find.widgetWithText(ListTile, 'Bank'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Mobile money'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Wallet'), findsOneWidget);
    });

    testWidgets('should show a payment type after valid search',
        (tester) async {
      await tester.pumpWidget(paymentTypesPageTestWidget());

      await tester.enterText(find.byType(TextFormField), 'Bank');
      await tester.pump();

      expect(find.byType(ListTile), findsExactly(1));
      expect(find.widgetWithText(ListTile, 'Bank'), findsOneWidget);
    });

    testWidgets('should show no payment types after invalid search',
        (tester) async {
      await tester.pumpWidget(paymentTypesPageTestWidget());

      await tester.enterText(find.byType(TextFormField), 'invalid');
      await tester.pump();

      expect(find.byType(ListTile), findsNothing);
    });
  });
}
