import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/send/send_did_page.dart';
import 'package:flutter/material.dart';
import 'package:didpay/features/send/send_page.dart';
import 'package:didpay/shared/number_pad.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web5/web5.dart';

import '../../helpers/widget_helpers.dart';

void main() async {
  final did = await DidJwk.create();

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

      expect(find.widgetWithText(FilledButton, 'Send'), findsOneWidget);
    });

    testWidgets('should change send amount after number pad press',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const SendPage()),
      );

      for (int i = 1; i <= 9; i++) {
        await tester.tap(find.text('$i'));
        await tester.pumpAndSettle();

        expect(find.text('\$$i'), findsOneWidget);

        await tester.tap(find.text('<'));
        await tester.pumpAndSettle();
      }

      expect(find.text('\$0'), findsOneWidget);
    });

    // TODO: uncomment this test as part of issue #81
    // testWidgets(
    //     'should pad send amount with a leading zero if send amount < a dollar',
    //     (tester) async {
    //   await tester.pumpWidget(
    //     WidgetHelpers.testableWidget(child: const SendPage()),
    //   );

    //   await tester.tap(find.text('.'));
    //   await tester.pumpAndSettle();

    //   expect(find.text('\$0.00'), findsOneWidget);
    // });

    testWidgets('should navigate to SendDidPage on tap of send button',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const SendPage(), overrides: [
          didProvider.overrideWithValue(did),
        ]),
      );

      await tester.tap(find.text('8'));
      await tester.pump();

      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();

      expect(find.byType(SendDidPage), findsOneWidget);
    });
  });
}
