import 'package:didpay/features/app/app_tabs.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/tbdex/tbdex_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/mocks.dart';
import '../../helpers/widget_helpers.dart';

void main() {
  testWidgets('should show AppTabs', (tester) async {
    await tester.pumpWidget(
      WidgetHelpers.testableWidget(
        child: const AppTabs(),
        overrides: [
          transactionsProvider.overrideWith(MockTransactionsNotifier.new),
          pfisProvider.overrideWith((ref) => MockPfisNotifier()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppTabs), findsOneWidget);
  });
}
