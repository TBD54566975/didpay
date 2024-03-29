import 'package:didpay/shared/pending_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/widget_helpers.dart';

void main() {
  group('PendingPage', () {
    testWidgets('should show request is pending', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const PendingPage(text: 'Your request is pending...'),
        ),
      );

      expect(find.text('Your request is pending...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
