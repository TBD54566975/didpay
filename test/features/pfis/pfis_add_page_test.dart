import 'package:didpay/features/pfis/pfis_add_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  group('PfisAddPage', () {
    Widget pfisAddPageTestWidget() => WidgetHelpers.testableWidget(
          child: const PfisAddPage(),
          overrides: [],
        );

    testWidgets('should show QR Code CTA', (tester) async {
      await tester.pumpWidget(pfisAddPageTestWidget());

      expect(
        find.widgetWithText(
          ListTile,
          "Don't know their DID? Scan their DID QR code instead",
        ),
        findsOneWidget,
      );
    });

    testWidgets('should show input field', (tester) async {
      await tester.pumpWidget(pfisAddPageTestWidget());

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should show add button', (tester) async {
      await tester.pumpWidget(pfisAddPageTestWidget());

      expect(find.widgetWithText(FilledButton, 'Add'), findsOneWidget);
    });
  });
}
