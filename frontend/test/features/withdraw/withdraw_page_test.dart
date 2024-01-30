import 'package:flutter_starter/features/withdraw/withdraw_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  group('WithdrawPage', () {
    testWidgets('should show withdraw input and output amounts',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const WithdrawPage()),
      );
      final depositAmountPattern = RegExp(r'\$[0-9]+\.[0-9]{2}$');

      expect(find.textContaining(depositAmountPattern), findsExactly(2));
    });

    testWidgets('should show you withdraw', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const WithdrawPage()),
      );

      expect(find.text('You withdraw'), findsOneWidget);
    });

    testWidgets('should show you get', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const WithdrawPage()),
      );

      expect(find.text('You get'), findsOneWidget);
    });

    testWidgets('should show est rate', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const WithdrawPage()),
      );

      expect(find.text('Est. rate'), findsOneWidget);
    });

    testWidgets('should show exchange rate', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const WithdrawPage()),
      );
      final exchangeRatePattern = RegExp(r'1 [A-Z]{3} = \d+ [A-Z]{3}');

      expect(find.textContaining(exchangeRatePattern), findsOneWidget);
    });

    testWidgets('should show service fee', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const WithdrawPage()),
      );

      expect(find.text('Service fee'), findsOneWidget);
    });

    testWidgets('should show next button', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const WithdrawPage()),
      );

      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('should change withdraw input amount after number pad press',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const WithdrawPage()),
      );

      for (int i = 1; i <= 9; i++) {
        await tester.tap(find.text('$i'));
        await tester.pump();

        final expectedText = i.toStringAsFixed(2);
        // ignore: unnecessary_brace_in_string_interps
        expect(find.text('\$${expectedText}'), findsOneWidget);

        await tester.tap(find.text('<'));
        await tester.pump();
      }
    });
  });
}
