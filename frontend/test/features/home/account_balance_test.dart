import 'package:flutter_starter/features/home/account_balance.dart';
import 'package:flutter_starter/features/deposit/deposit_page.dart';
import 'package:flutter_starter/features/withdraw/withdraw_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  group('AccountBalance', () {
    testWidgets('should show account balance', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const AccountBalance()),
      );

      expect(find.text('Account balance'), findsOneWidget);
    });

    testWidgets('should show valid account balance amount', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const AccountBalance()),
      );

      final dollarAmountPattern = RegExp(r'\$[0-9]+\.[0-9]{2}$');

      expect(find.textContaining(dollarAmountPattern), findsOneWidget);
    });

    testWidgets('should show deposit button', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const AccountBalance()),
      );

      expect(find.text('Deposit'), findsOneWidget);
    });

    testWidgets('should navigate to Deposit screen on tap of deposit button',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const AccountBalance()),
      );

      await tester.tap(find.text('Deposit'));
      await tester.pumpAndSettle();

      expect(find.byType(DepositPage), findsOneWidget);
    });

    testWidgets('should show withdraw button', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const AccountBalance()),
      );

      expect(find.text('Withdraw'), findsOneWidget);
    });

    testWidgets('should navigate to Withdraw screen on tap of withdraw button',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: const AccountBalance()),
      );

      await tester.tap(find.text('Withdraw'));
      await tester.pumpAndSettle();

      expect(find.byType(WithdrawPage), findsOneWidget);
    });
  });
}
