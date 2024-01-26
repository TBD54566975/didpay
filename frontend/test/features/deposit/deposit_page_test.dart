import 'package:flutter_starter/features/deposit/deposit_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  group('DepositPage', () {
    testWidgets('should show you deposit', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const DepositPage()),
      );

      expect(find.text('You deposit'), findsOneWidget);
    });
  });
}
