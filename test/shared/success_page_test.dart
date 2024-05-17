import 'package:didpay/shared/success_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/widget_helpers.dart';

void main() {
  group('SuccessPage', () {
    testWidgets('should show request was submitted', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const SuccessState(text: 'Your request was submitted!'),
        ),
      );

      expect(find.text('Your request was submitted!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should show done button', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const SuccessState(
            text: '',
          ),
        ),
      );

      expect(find.widgetWithText(FilledButton, 'Done'), findsOneWidget);
    });
  });
}
