import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/send/send_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web5/web5.dart';

import '../../helpers/widget_helpers.dart';

void main() async {
  final did = await DidDht.create();

  group('SendDetailsPage', () {
    Widget sendDetailsPageTestWidget() => WidgetHelpers.testableWidget(
          child: const SendDetailsPage(sendAmount: '25'),
          overrides: [
            didProvider.overrideWithValue(did),
          ],
        );

    testWidgets('should show QR Code CTA', (tester) async {
      await tester.pumpWidget(sendDetailsPageTestWidget());

      expect(
        find.widgetWithText(
          ListTile,
          "Don't know their DID? Scan their DID QR code instead",
        ),
        findsOneWidget,
      );
    });

    testWidgets('should show input field', (tester) async {
      await tester.pumpWidget(sendDetailsPageTestWidget());

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should show send button', (tester) async {
      await tester.pumpWidget(sendDetailsPageTestWidget());

      expect(find.widgetWithText(FilledButton, 'Send 25 USDC'), findsOneWidget);
    });
  });
}
