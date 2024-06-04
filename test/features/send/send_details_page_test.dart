import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/send/send_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web5/web5.dart';

import '../../helpers/widget_helpers.dart';

void main() async {
  final did = await DidDht.create();

  group('SendDetailsPage', () {
    testWidgets('should show QR Code CTA', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: SendDetailsPage(sendAmount: '25'),
          overrides: [
            didProvider.overrideWithValue(did),
          ],
        ),
      );

      expect(find.textContaining('Scan their QR code'), findsOneWidget);
    });

    testWidgets('should show input field', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: SendDetailsPage(sendAmount: '25'),
          overrides: [
            didProvider.overrideWithValue(did),
          ],
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should show send button', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: SendDetailsPage(sendAmount: '25'),
          overrides: [
            didProvider.overrideWithValue(did),
          ],
        ),
      );

      expect(find.widgetWithText(FilledButton, 'Send 25 USDC'), findsOneWidget);
    });
  });
}
