import 'package:didpay/features/account/account_page.dart';
import 'package:didpay/features/app/app_tabs.dart';
import 'package:didpay/features/home/home_page.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/send/send_page.dart';
import 'package:didpay/features/tbdex/transactions_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/mocks.dart';
import '../../helpers/widget_helpers.dart';

void main() {
  group('AppTabs', () {
    testWidgets('should start on HomePage', (tester) async {
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

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should show SendPage when tapped', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const AppTabs(),
          overrides: [
            transactionsProvider.overrideWith(MockTransactionsNotifier.new),
            pfisProvider.overrideWith((ref) => MockPfisNotifier()),
          ],
        ),
      );

      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();
      expect(find.byType(SendPage), findsOneWidget);
    });

    testWidgets('should show AccountPage when tapped', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const AppTabs(),
          overrides: [
            transactionsProvider.overrideWith(MockTransactionsNotifier.new),
            pfisProvider.overrideWith((ref) => MockPfisNotifier()),
          ],
        ),
      );

      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();
      expect(find.byType(AccountPage), findsOneWidget);
    });
  });
}
