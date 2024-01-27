import 'package:flutter/material.dart';
import 'package:flutter_starter/shared/number_pad.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/widget_helpers.dart';

void main() {
  List<String> numberKeys = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '0',
    '.',
    '<',
  ];

  group('NumberPad', () {
    testWidgets('should show all number keys', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: NumberPad(
            enteredAmount: ValueNotifier<String>('0'),
          ),
        ),
      );

      for (String key in numberKeys) {
        expect(find.text(key), findsOneWidget);
      }
    });

    testWidgets('should get entered amount', (tester) async {
      var enteredAmount = ValueNotifier<String>('0');
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: NumberPad(
            enteredAmount: enteredAmount,
          ),
        ),
      );

      for (int i = 0; i <= 3; i++) {
        await tester.tap(find.text('$i'));
        await tester.pump();
      }

      await tester.tap(find.text('<'));
      await tester.pump();

      expect(enteredAmount.value, '12');
    });
  });
}
