import 'package:flutter_starter/features/deposit/deposit_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  group('DepositPage', () {
    testWidgets('should show deposit input and output amounts', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const DepositPage()),
      );

      expect(find.textContaining('\$0'), findsExactly(2));
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

    testWidgets('should show est rate', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const DepositPage()),
      );

      expect(find.text('Est. rate'), findsOneWidget);
    });

    testWidgets('should show exchange rate', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const DepositPage()),
      );
      final exchangeRatePattern = RegExp(r'1 [A-Z]{3} = \d+ [A-Z]{3}');

      expect(find.textContaining(exchangeRatePattern), findsOneWidget);
    });

    testWidgets('should show service fee', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const DepositPage()),
      );

      expect(find.text('Service fee'), findsOneWidget);
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

        expect(find.textContaining('\$$i'), findsOneWidget);

        await tester.tap(find.text('<'));
        await tester.pump();
      }
    });
  });
}
