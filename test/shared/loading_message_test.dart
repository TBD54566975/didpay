import 'package:didpay/shared/loading_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/widget_helpers.dart';

void main() {
  group('LoadingMessage', () {
    testWidgets('should show request is pending', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const LoadingMessage(message: 'Your request is pending...'),
        ),
      );

      expect(find.text('Your request is pending...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
