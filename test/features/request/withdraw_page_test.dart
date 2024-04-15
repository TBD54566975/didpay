import 'package:didpay/features/currency/payin.dart';
import 'package:didpay/features/currency/payout.dart';
import 'package:didpay/features/request/withdraw_page.dart';
import 'package:didpay/shared/fee_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  group('WithdrawPage', () {
    testWidgets('should show Currency Converter', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const WithdrawPage()),
      );

      expect(find.byType(Payin), findsOneWidget);
      expect(find.byType(Payout), findsOneWidget);
    });

    testWidgets('should show Fee Details', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const WithdrawPage()),
      );

      expect(find.byType(FeeDetails), findsOneWidget);
    });

    testWidgets('should show next button', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const WithdrawPage()),
      );

      expect(find.widgetWithText(FilledButton, 'Next'), findsOneWidget);
    });

    testWidgets('should show disabled next button while payin in 0',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const WithdrawPage()),
      );

      final nextButton = find.widgetWithText(FilledButton, 'Next');

      expect(
        tester.widget<FilledButton>(nextButton).onPressed,
        isNull,
      );
    });

    testWidgets('should show enabled next button when payin is not 0',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const WithdrawPage()),
      );

      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      final nextButton = find.widgetWithText(FilledButton, 'Next');

      expect(
        tester.widget<FilledButton>(nextButton).onPressed,
        isNotNull,
      );
    });

    testWidgets('should change withdraw input amount after number pad press',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const WithdrawPage()),
      );

      for (var i = 1; i <= 9; i++) {
        await tester.tap(find.text('$i'));
        await tester.pumpAndSettle();

        expect(find.text('$i'), findsAtLeast(1));

        await tester.tap(find.text('<'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets(
        'should show the currency list on tap of the currency converter dropdown toggle',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const WithdrawPage()),
      );

      await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
