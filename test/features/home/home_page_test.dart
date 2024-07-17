import 'package:didpay/features/account/account_balance_card.dart';
import 'package:didpay/features/account/account_balance_notifier.dart';
import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/home/home_page.dart';
import 'package:didpay/features/payment/payment_amount_state.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/features/transaction/transaction_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';
import '../../helpers/widget_helpers.dart';

void main() async {
  await TestData.initializeDids();

  final did = TestData.aliceDid;
  final pfis = TestData.getPfis();
  final offerings = TestData.getOfferingsMap();
  final accountBalance = TestData.getAccountBalance();

  late MockTbdexService mockTbdexService;
  late MockPfisNotifier mockPfisNotifier;

  group('HomePage', () {
    Widget homePageTestWidget() => WidgetHelpers.testableWidget(
          child: const HomePage(),
          overrides: [
            didProvider.overrideWithValue(did),
            tbdexServiceProvider.overrideWith((ref) => mockTbdexService),
            transactionProvider.overrideWith(MockTransactionNotifier.new),
            accountBalanceProvider
                .overrideWith(() => MockAccountBalanceNotifier(accountBalance)),
            pfisProvider.overrideWith((ref) => mockPfisNotifier),
          ],
        );

    setUp(() {
      mockTbdexService = MockTbdexService();
      mockPfisNotifier = MockPfisNotifier(pfis);

      when(
        () => mockTbdexService.getOfferings(
          pfis,
          payinCurrency: 'USDC',
        ),
      ).thenAnswer((_) async => offerings);

      when(
        () => mockTbdexService.getExchanges(did, pfis),
      ).thenAnswer((_) async => {});

      when(
        () => mockTbdexService.getAccountBalance(pfis),
      ).thenAnswer(
        (_) async => accountBalance,
      );
    });

    setUpAll(
      () => registerFallbackValue(
        PaymentState(
          transactionType: TransactionType.deposit,
          paymentAmountState: PaymentAmountState(offeringsMap: offerings),
        ),
      ),
    );

    testWidgets('should show account balance', (tester) async {
      await tester.pumpWidget(homePageTestWidget());

      expect(find.text('Account balance'), findsOneWidget);
    });

    testWidgets('should show account balance amount', (tester) async {
      await tester.pumpWidget(homePageTestWidget());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AccountBalanceCard, '0'), findsOneWidget);
      expect(find.widgetWithText(AccountBalanceCard, 'USD'), findsOneWidget);
    });

    testWidgets('should show deposit button', (tester) async {
      await tester.pumpWidget(homePageTestWidget());

      expect(find.widgetWithText(FilledButton, 'Deposit'), findsOneWidget);
    });

    testWidgets('should show withdraw button', (tester) async {
      await tester.pumpWidget(homePageTestWidget());

      expect(find.widgetWithText(FilledButton, 'Withdraw'), findsOneWidget);
    });

    testWidgets('should show empty state when no transactions', (tester) async {
      await tester.pumpWidget(homePageTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No transactions yet'), findsOneWidget);
      expect(
        find.text('Start by adding funds to your account!'),
        findsOneWidget,
      );
      expect(find.text('Get started'), findsOneWidget);
    });
  });
}
