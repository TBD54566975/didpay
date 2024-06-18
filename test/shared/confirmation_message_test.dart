import 'package:didpay/shared/confirmation_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/widget_helpers.dart';

void main() {
  group('ConfirmationMessage', () {
    testWidgets('should show request was submitted', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child:
              const ConfirmationMessage(message: 'Your request was submitted!'),
        ),
      );

      expect(find.text('Your request was submitted!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should show done button', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const ConfirmationMessage(
            message: '',
          ),
        ),
      );

      expect(find.widgetWithText(FilledButton, 'Done'), findsOneWidget);
    });
  });
}
