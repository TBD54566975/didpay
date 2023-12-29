import 'package:flutter_starter/features/app/app_tabs.dart';
import 'package:flutter_starter/features/sample/sample_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  testWidgets('should start on CounterPage', (WidgetTester tester) async {
    await tester.pumpWidget(
      WidgetHelpers.testableWidget(child: const AppTabs()),
    );

    expect(find.byType(SamplePage), findsOneWidget);
  });

  testWidgets('should show TodosPage when tapped', (WidgetTester tester) async {
    await tester.pumpWidget(
      WidgetHelpers.testableWidget(child: const AppTabs()),
    );

    await tester.tap(find.text('Tab 2'));
    await tester.pumpAndSettle();
    expect(find.byType(SamplePage), findsOneWidget);
  });
}
