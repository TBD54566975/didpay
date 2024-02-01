import 'package:flutter/material.dart';
import 'package:flutter_starter/features/send/send_did_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  group('SendDidPage', () {
    testWidgets('should show amount to send', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
            child: const SendDidPage(sendAmount: '25')),
      );

      expect(find.textContaining('\$25'), findsNWidgets(2));
    });

    testWidgets('should show Account Balance', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
            child: const SendDidPage(sendAmount: '25')),
      );

      expect(find.text('Account balance'), findsOneWidget);
    });

    testWidgets('should show QR Code CTA', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
            child: const SendDidPage(sendAmount: '25')),
      );

      expect(find.textContaining('Scan their QR code'), findsOneWidget);
    });

    testWidgets('should show input field', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
            child: const SendDidPage(sendAmount: '25')),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should show pay button', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
            child: const SendDidPage(sendAmount: '25')),
      );

      expect(find.text('Pay \$25'), findsOneWidget);
    });
  });
}
