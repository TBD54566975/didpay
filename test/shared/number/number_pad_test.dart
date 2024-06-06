import 'package:didpay/shared/number/number_pad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  var numberKeys = <String>[
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
            onKeyPressed: (_) => {},
          ),
        ),
      );

      for (final key in numberKeys) {
        expect(find.text(key), findsOneWidget);
      }
    });

    testWidgets('should get entered amount', (tester) async {
      final text = ValueNotifier<String>('0');
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: NumberPad(
            onKeyPressed: (key) => text.value = key,
          ),
        ),
      );

      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('$i'));
        await tester.pump();
        expect(text.value, i.toString());
      }
    });
  });
}
