import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:didpay/features/pfis/pfi_page.dart';
import '../../helpers/widget_helpers.dart';

void main() {
  group('PfiPage', () {
    testWidgets('PFI page should have required widgets',
        (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const PfiPage(),
        ),
      );

      // Wait for all animations and scheduled frames to complete
      await tester.pumpAndSettle();

      // Verify the title 'Get started with a PFI' is present
      expect(find.text('Get started with a PFI'), findsOneWidget);

      // Verify the 'Scan QR Code' button is present
      expect(
          find.widgetWithText(ElevatedButton, 'Scan QR Code'), findsOneWidget);
    });
  });
}
