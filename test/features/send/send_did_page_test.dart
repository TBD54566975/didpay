import 'package:flutter/material.dart';
import 'package:didpay/features/send/send_did_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  group('SendDidPage', () {
    testWidgets('should show amount to send', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: SendDidPage(sendAmount: '25')),
      );

      expect(find.textContaining('\$25'), findsOneWidget);
    });

    testWidgets('should show QR Code CTA', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: SendDidPage(sendAmount: '25')),
      );

      expect(find.textContaining('Scan their QR code'), findsOneWidget);
    });

    testWidgets('should show input field', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: SendDidPage(sendAmount: '25')),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should show pay button', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: SendDidPage(sendAmount: '25')),
      );

      expect(find.widgetWithText(FilledButton, 'Pay \$25'), findsOneWidget);
    });
  });
}
