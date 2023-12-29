import 'package:flutter_starter/features/app/app.dart';
import 'package:flutter_starter/features/app/app_tabs.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  testWidgets('should show AppTabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      WidgetHelpers.testableWidget(child: const App()),
    );

    expect(find.byType(AppTabs), findsOneWidget);
  });
}
