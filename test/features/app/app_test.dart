import 'package:didpay/features/app/app.dart';
import 'package:didpay/features/onboarding/welcome_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  testWidgets('should show AppTabs', (tester) async {
    await tester.pumpWidget(
      WidgetHelpers.testableWidget(child: const App(onboarding: true)),
    );

    expect(find.byType(WelcomePage), findsOneWidget);
  });
}
