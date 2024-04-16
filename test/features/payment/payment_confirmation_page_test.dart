import 'package:didpay/features/payment/payment_confirmation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  group('PaymentConfirmationPage', () {
    testWidgets('should show sending payment', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          WidgetHelpers.testableWidget(
            child: const PaymentConfirmationPage(),
          ),
        );

        expect(find.text('Sending payment...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    testWidgets('should show payment was sent', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const PaymentConfirmationPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Your payment was sent!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}
