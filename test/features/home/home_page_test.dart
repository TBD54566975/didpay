import 'dart:convert';

import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/home/home_page.dart';
import 'package:didpay/features/payin/deposit_page.dart';
import 'package:didpay/features/payout/withdraw_page.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/tbdex/transaction_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbdex/tbdex.dart';
import 'package:web5/web5.dart';

import '../../helpers/mocks.dart';
import '../../helpers/widget_helpers.dart';

void main() async {
  final did = await DidDht.create();

  const jsonString =
      r'''[{"metadata":{"kind":"offering","from":"did:web:localhost%3A8892:ingress","id":"offering_01hv22zfv1eptadkm92v278gh9","protocol":"1.0","createdAt":"2024-04-12T20:57:11Z","updatedAt":"2024-04-12T20:57:11Z"},"data":{"description":"MXN for USD","payoutUnitsPerPayinUnit":"16.34","payin":{"currencyCode":"USD","methods":[{"kind":"STORED_BALANCE","name":"Account balance"}]},"payout":{"currencyCode":"MXN","methods":[{"kind":"SPEI","estimatedSettlementTime":300,"name":"SPEI","requiredPaymentDetails":{"$schema":"http://json-schema.org/draft-07/schema#","additionalProperties":false,"properties":{"clabe":{"type":"string"},"fullName":{"type":"string"}},"required":["clabe","fullName"]}}]}},"signature":"eyJhbGciOiJFZERTQSIsImtpZCI6ImRpZDp3ZWI6bG9jYWxob3N0JTNBODg5MjppbmdyZXNzIzAifQ..le65W3WyI2UKMJojADv_lTQixt0wDmnMMBVaWC_2BaYVQfe8HY3gQyPqbI4dT-iDNRjg_EdlCvTiEzANfp0lDw"}]''';
  const pfi = Pfi(did: 'did:web:x%3A8892:ingress');

  final jsonList = jsonDecode(jsonString) as List<dynamic>;
  final offerings = [Offering.fromJson(jsonList[0])];
  late MockTbdexService mockTbdexService;

  group('HomePage', () {
    setUp(() {
      mockTbdexService = MockTbdexService();

      when(
        () => mockTbdexService.getOfferings([pfi]),
      ).thenAnswer((_) async => offerings);

      when(
        () => mockTbdexService.getExchanges(did, [pfi]),
      ).thenAnswer((_) async => {});
    });

    testWidgets('should show account balance', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const HomePage(),
          overrides: [
            didProvider.overrideWithValue(did),
            tbdexServiceProvider.overrideWith((ref) => mockTbdexService),
            transactionProvider.overrideWith(MockTransactionNotifier.new),
            pfisProvider.overrideWith((ref) => MockPfisNotifier()),
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
            didProvider.overrideWithValue(did),
            tbdexServiceProvider.overrideWith((ref) => mockTbdexService),
            transactionProvider.overrideWith(MockTransactionNotifier.new),
            pfisProvider.overrideWith((ref) => MockPfisNotifier()),
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
            didProvider.overrideWithValue(did),
            tbdexServiceProvider.overrideWith((ref) => mockTbdexService),
            transactionProvider.overrideWith(MockTransactionNotifier.new),
            pfisProvider.overrideWith((ref) => MockPfisNotifier()),
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
            didProvider.overrideWithValue(did),
            tbdexServiceProvider.overrideWith((ref) => mockTbdexService),
            transactionProvider.overrideWith(MockTransactionNotifier.new),
            pfisProvider.overrideWith((ref) => MockPfisNotifier()),
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
            didProvider.overrideWithValue(did),
            tbdexServiceProvider.overrideWith((ref) => mockTbdexService),
            transactionProvider.overrideWith(MockTransactionNotifier.new),
            pfisProvider.overrideWith((ref) => MockPfisNotifier()),
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
            didProvider.overrideWithValue(did),
            tbdexServiceProvider.overrideWith((ref) => mockTbdexService),
            transactionProvider.overrideWith(MockTransactionNotifier.new),
            pfisProvider.overrideWith((ref) => MockPfisNotifier()),
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
            didProvider.overrideWithValue(did),
            tbdexServiceProvider.overrideWith((ref) => mockTbdexService),
            transactionProvider.overrideWith(MockTransactionNotifier.new),
            pfisProvider.overrideWith((ref) => MockPfisNotifier()),
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
            didProvider.overrideWithValue(did),
            tbdexServiceProvider.overrideWith((ref) => mockTbdexService),
            transactionProvider.overrideWith(MockTransactionNotifier.new),
            pfisProvider.overrideWith((ref) => MockPfisNotifier()),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();

      expect(find.byType(DepositPage), findsOneWidget);
    });
  });
}
