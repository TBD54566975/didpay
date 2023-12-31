import 'package:flutter_starter/features/account/account_page.dart';
import 'package:flutter_starter/features/app/app_tabs.dart';
import 'package:flutter_starter/features/home/home_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  testWidgets('should start on HomePage', (WidgetTester tester) async {
    await tester.pumpWidget(
      WidgetHelpers.testableWidget(child: const AppTabs()),
    );

    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('should show AccountPage when tapped',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      WidgetHelpers.testableWidget(child: const AppTabs()),
    );

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    expect(find.byType(AccountPage), findsOneWidget);
  });
}
