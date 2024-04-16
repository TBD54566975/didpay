import 'package:didpay/features/pfis/pfi_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  group('PfiPage', () {
    testWidgets('PFI page should have required widgets',
        (tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const PfiPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Get started with a PFI'), findsOneWidget);

      expect(
          find.widgetWithText(ElevatedButton, 'Scan QR Code'), findsOneWidget,);
    });
  });
}
