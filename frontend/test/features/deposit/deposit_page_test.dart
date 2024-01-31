import 'package:flutter_starter/features/deposit/deposit_page.dart';
import 'package:flutter_starter/shared/fee_details.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  group('DepositPage', () {
    testWidgets('should show deposit input and output amounts', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const DepositPage()),
      );
      final depositAmountPattern = RegExp(r'\$[0-9]+\.[0-9]{2}$');

      expect(find.textContaining(depositAmountPattern), findsExactly(2));
    });

    testWidgets('should show you deposit', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const DepositPage()),
      );

      expect(find.text('You deposit'), findsOneWidget);
    });

    testWidgets('should show you get', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const DepositPage()),
      );

      expect(find.text('You get'), findsOneWidget);
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

      expect(find.text('Next'), findsOneWidget);
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
