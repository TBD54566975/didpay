import 'package:flutter/material.dart';
import 'package:flutter_starter/features/deposit/deposit_page.dart';
import 'package:flutter_starter/shared/currency_converter.dart';
import 'package:flutter_starter/shared/fee_details.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  group('DepositPage', () {
    testWidgets('should show Currency Converter', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const DepositPage()),
      );

      expect(find.byType(CurrencyConverter), findsOneWidget);
    });

    testWidgets('should show Fee Details', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const DepositPage()),
      );

      expect(find.byType(FeeDetails), findsOneWidget);
    });

    testWidgets('should show next button', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const DepositPage()),
      );

      expect(find.widgetWithText(FilledButton, 'Next'), findsOneWidget);
    });

    testWidgets('should change deposit input amount after number pad press',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const DepositPage()),
      );

      for (int i = 1; i <= 9; i++) {
        await tester.tap(find.text('$i'));
        await tester.pump();

        final expectedText = i.toStringAsFixed(2);
        expect(find.textContaining(expectedText), findsOneWidget);

        await tester.tap(find.text('<'));
        await tester.pump();
      }
    });
  });
}
