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
            onKeyPressed: (key) {},
            onDeletePressed: () {},
          ),
        ),
      );

      for (String key in numberKeys) {
        expect(find.text(key), findsOneWidget);
      }
    });

    testWidgets('should call onKeyPressed when a key is pressed',
        (tester) async {
      var pressedKey = '';
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: NumberPad(
            onKeyPressed: (key) {
              pressedKey = key;
            },
            onDeletePressed: () {},
          ),
        ),
      );

      // exclude the delete key '<'
      for (String key in numberKeys.sublist(0, numberKeys.length - 1)) {
        await tester.tap(find.text(key));
        expect(pressedKey, key);
      }
    });

    testWidgets('should call onDeletePressed when delete key is pressed',
        (tester) async {
      var deletePressed = false;
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: NumberPad(
            onKeyPressed: (key) {},
            onDeletePressed: () {
              deletePressed = true;
            },
          ),
        ),
      );

      await tester.tap(find.text('<'));
      expect(deletePressed, true);
    });
  });
}
