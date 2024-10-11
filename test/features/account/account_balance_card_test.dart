import 'package:didpay/features/account/account_balance_card.dart';
import 'package:didpay/features/account/account_balance_notifier.dart';
import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';
import '../../helpers/widget_helpers.dart';

void main() async {
  await TestData.initializeDids();

  final accountBalance = TestData.getAccountBalance();
  final did = TestData.aliceDid;
  final pfis = TestData.getPfis();

  late MockPfisNotifier mockPfisNotifier;
  late MockAccountBalanceNotifier mockAccountBalanceNotifier;

  group('AccountBalanceCard', () {
    setUpAll(() {
      registerFallbackValue(did);
      registerFallbackValue(pfis);
    });

    setUp(() {
      mockPfisNotifier = MockPfisNotifier(pfis);
      mockAccountBalanceNotifier = MockAccountBalanceNotifier(accountBalance);

      when(
        () => mockAccountBalanceNotifier.startPolling(any(), any()),
      ).thenAnswer((_) async => accountBalance);
    });

    Widget accountBalanceCardTestWidget({
      bool pfisIsEmpty = false,
    }) =>
        WidgetHelpers.testableWidget(
          child: const AccountBalanceCard(),
          overrides: [
            pfisProvider.overrideWith(
              (ref) => pfisIsEmpty ? MockPfisNotifier([]) : mockPfisNotifier,
            ),
            accountBalanceProvider
                .overrideWith(() => mockAccountBalanceNotifier),
            didProvider.overrideWith((ref) => did),
          ],
        );

    testWidgets('should show account balance title', (tester) async {
      await tester.pumpWidget(accountBalanceCardTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Account balance'), findsOneWidget);
    });

    testWidgets('should show account balance amount', (tester) async {
      await tester.pumpWidget(accountBalanceCardTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('101'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
    });

    group('if pfis is empty', () {
      testWidgets('should not show deposit button', (tester) async {
        await tester
            .pumpWidget(accountBalanceCardTestWidget(pfisIsEmpty: true));
        await tester.pumpAndSettle();

        expect(find.widgetWithText(FilledButton, 'Deposit'), findsNothing);
      });

      testWidgets('should not show withdraw button', (tester) async {
        await tester
            .pumpWidget(accountBalanceCardTestWidget(pfisIsEmpty: true));
        await tester.pumpAndSettle();

        expect(find.widgetWithText(FilledButton, 'Withdraw'), findsNothing);
      });
    });

    group('if pfis is not empty', () {
      testWidgets('should show deposit button', (tester) async {
        await tester.pumpWidget(accountBalanceCardTestWidget());
        await tester.pumpAndSettle();

        expect(find.widgetWithText(FilledButton, 'Deposit'), findsOneWidget);
      });

      testWidgets('should show withdraw button', (tester) async {
        await tester.pumpWidget(accountBalanceCardTestWidget());
        await tester.pumpAndSettle();

        expect(find.widgetWithText(FilledButton, 'Withdraw'), findsOneWidget);
      });
    });
  });
}
