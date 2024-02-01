import 'package:flutter_starter/features/send/send_did_page.dart';
import 'package:flutter_starter/features/send/send_page.dart';
import 'package:flutter_starter/shared/number_pad.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  group('SendPage', () {
    testWidgets('should show Number Pad', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const SendPage()),
      );

      expect(find.byType(NumberPad), findsOneWidget);
    });

    testWidgets('should show send button', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const SendPage()),
      );

      expect(find.text('Send'), findsOneWidget);
    });

    testWidgets('should change send amount after number pad press',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const SendPage()),
      );

      for (int i = 1; i <= 9; i++) {
        await tester.tap(find.text('$i'));
        await tester.pump();

        expect(find.text('\$$i'), findsOneWidget);

        await tester.tap(find.text('<'));
        await tester.pump();
      }

      expect(find.text('\$0'), findsOneWidget);
    });

    testWidgets(
        'should pad send amount with a leading zero if send amount < a dollar',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const SendPage()),
      );

      await tester.tap(find.text('.'));
      await tester.pump();

      expect(find.text('\$0.'), findsOneWidget);
    });

    testWidgets('should navigate to SendDidPage on tap of send button',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const SendPage()),
      );

      await tester.tap(find.text('Send'));
      await tester.pump();

      expect(find.byType(SendDidPage), findsOneWidget);
    });
  });
}
