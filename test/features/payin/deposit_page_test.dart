import 'package:didpay/features/payin/deposit_page.dart';
import 'package:didpay/features/payin/payin.dart';
import 'package:didpay/features/payout/payout.dart';
import 'package:didpay/shared/fee_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  group('DepositPage', () {
    testWidgets('should show payin and payout', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const DepositPage()),
      );

      expect(find.byType(Payin), findsOneWidget);
      expect(find.byType(Payout), findsOneWidget);
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
        WidgetHelpers.testableWidget(child: const DepositPage()),
      );

      await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
