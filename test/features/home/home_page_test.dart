import 'package:didpay/features/home/home_page.dart';
import 'package:didpay/features/payin/deposit_page.dart';
import 'package:didpay/features/payout/withdraw_page.dart';
import 'package:didpay/features/tbdex/tbdex_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/mocks.dart';
import '../../helpers/widget_helpers.dart';

void main() {
  group('HomePage', () {
    testWidgets('should show account balance', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const HomePage(),
          overrides: [
            transactionsProvider.overrideWith(MockTransactionsNotifier.new),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Account balance'), findsOneWidget);
    });

    testWidgets('should show valid account balance amount', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const HomePage(),
          overrides: [
            transactionsProvider.overrideWith(MockTransactionsNotifier.new),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final numberPattern = RegExp(r'[0-9]+(\.[0-9]{2})?$');

      expect(find.textContaining(numberPattern), findsOneWidget);
    });

    testWidgets('should show deposit button', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const HomePage(),
          overrides: [
            transactionsProvider.overrideWith(MockTransactionsNotifier.new),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(FilledButton, 'Deposit'), findsOneWidget);
    });

    testWidgets('should navigate to DepositPage on tap of deposit button',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const HomePage(),
          overrides: [
            transactionsProvider.overrideWith(MockTransactionsNotifier.new),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Deposit'));
      await tester.pumpAndSettle();

      expect(find.byType(DepositPage), findsOneWidget);
    });

    testWidgets('should show withdraw button', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const HomePage(),
          overrides: [
            transactionsProvider.overrideWith(MockTransactionsNotifier.new),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(FilledButton, 'Withdraw'), findsOneWidget);
    });

    testWidgets('should navigate to WithdrawPage on tap of withdraw button',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const HomePage(),
          overrides: [
            transactionsProvider.overrideWith(MockTransactionsNotifier.new),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Withdraw'));
      await tester.pumpAndSettle();

      expect(find.byType(WithdrawPage), findsOneWidget);
    });

    testWidgets('should show empty state when no transactions', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const HomePage(),
          overrides: [
            transactionsProvider.overrideWith(MockTransactionsNotifier.new),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No transactions yet'), findsOneWidget);
      expect(
        find.text('Start by adding funds to your account!'),
        findsOneWidget,
      );
      expect(find.text('Get started'), findsOneWidget);
    });

    testWidgets('should navigate to DepositPage on tap of get started button',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const HomePage(),
          overrides: [
            transactionsProvider.overrideWith(MockTransactionsNotifier.new),
          ],
        ),
      );

      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();

      expect(find.byType(DepositPage), findsOneWidget);
    });
  });
}
