import 'package:didpay/features/request/request_confirmation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  group('RequestConfirmationPage', () {
    testWidgets('should show sending payment', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          WidgetHelpers.testableWidget(
            child: const RequestConfirmationPage(),
          ),
        );

        expect(find.text('Sending request...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    testWidgets('should show payment was sent', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const RequestConfirmationPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Your request was sent!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}
