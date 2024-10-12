import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/features/transaction/transaction_details_page.dart';
import 'package:didpay/features/transaction/transaction_notifier.dart';
import 'package:didpay/features/transaction/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';
import '../../helpers/widget_helpers.dart';

void main() {
  group('TransactionTile', () {
    final pfi = TestData.getPfi('did:dht:pfiDid');
    const exchangeId = 'rfq_01ha835rhefwmagsknrrhvaa0k';

    final sendTransaction = TestData.getTransaction();
    final depositTransaction = TestData.getTransaction(
      type: TransactionType.deposit,
    );
    final withdrawTransaction = TestData.getTransaction(
      type: TransactionType.withdraw,
    );

    const mockTransactionNotifierWithSendTransaction =
        MockTransactionNotifierWithData(
      transactionType: TransactionType.send,
    );
    const mockTransactionNotifierWithDepositTransaction =
        MockTransactionNotifierWithData(
      transactionType: TransactionType.deposit,
    );
    const mockTransactionNotifierWithWithdrawTransaction =
        MockTransactionNotifierWithData(
      transactionType: TransactionType.withdraw,
    );
    const mockTransactionNotifierWithNullData =
        MockTransactionNotifierWithNullData();
    const mockTransactionNotifierWithError = MockTransactionNotifierWithError();

    late MockTransactionNotifier mockSendTransactionNotifier;
    late MockTransactionNotifier mockDepositTransactionNotifier;
    late MockTransactionNotifier mockWithdrawTransactionNotifier;
    late MockTransactionNotifier nullMockTransactionNotifier;
    late MockTransactionNotifier erroringMockTransactionNotifier;

    setUp(() {
      mockSendTransactionNotifier =
          MockTransactionNotifier(() => sendTransaction);
      mockDepositTransactionNotifier =
          MockTransactionNotifier(() => depositTransaction);
      mockWithdrawTransactionNotifier =
          MockTransactionNotifier(() => withdrawTransaction);
      nullMockTransactionNotifier = MockTransactionNotifier();
      erroringMockTransactionNotifier = MockTransactionNotifier(
        () => throw StateError('Error loading transaction'),
      );
    });

    Widget transactionTileTestWidget({
      required MockTransactionNotifierType mockTransactionNotifierType,
    }) =>
        WidgetHelpers.testableWidget(
          child: TransactionTile(
            pfi: pfi,
            exchangeId: exchangeId,
          ),
          overrides: [
            transactionProvider.overrideWith(
              () => switch (mockTransactionNotifierType) {
                MockTransactionNotifierWithData() => switch (
                      mockTransactionNotifierType.transactionType) {
                    TransactionType.send => mockSendTransactionNotifier,
                    TransactionType.deposit => mockDepositTransactionNotifier,
                    TransactionType.withdraw => mockWithdrawTransactionNotifier,
                  },
                MockTransactionNotifierWithNullData() =>
                  nullMockTransactionNotifier,
                MockTransactionNotifierWithError() =>
                  erroringMockTransactionNotifier,
              },
            ),
          ],
        );

    testWidgets('should show paying and payout currencies', (tester) async {
      await tester.pumpWidget(
        transactionTileTestWidget(
          mockTransactionNotifierType:
              mockTransactionNotifierWithSendTransaction,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('AUD → BTC'), findsOneWidget);
    });

    testWidgets('should show transaction status', (tester) async {
      await tester.pumpWidget(
        transactionTileTestWidget(
          mockTransactionNotifierType:
              mockTransactionNotifierWithSendTransaction,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Order submitted'), findsOneWidget);
    });

    testWidgets('should show error if transaction is null', (tester) async {
      await tester.pumpWidget(
        transactionTileTestWidget(
          mockTransactionNotifierType: mockTransactionNotifierWithNullData,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No transactions found'), findsOneWidget);
    });

    testWidgets('should show error when transaction fetch returns an error',
        (tester) async {
      await tester.pumpWidget(
        transactionTileTestWidget(
          mockTransactionNotifierType: mockTransactionNotifierWithError,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bad state: Error loading transaction'), findsOneWidget);
    });

    group('should show transaction amount in correct format for ', () {
      testWidgets('send transactions', (tester) async {
        await tester.pumpWidget(
          transactionTileTestWidget(
            mockTransactionNotifierType:
                mockTransactionNotifierWithSendTransaction,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('-100.01 AUD'), findsOneWidget);
      });

      testWidgets('deposit transactions', (tester) async {
        await tester.pumpWidget(
          transactionTileTestWidget(
            mockTransactionNotifierType:
                mockTransactionNotifierWithDepositTransaction,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('+0.12 BTC'), findsOneWidget);
      });

      testWidgets('withdraw transactions', (tester) async {
        await tester.pumpWidget(
          transactionTileTestWidget(
            mockTransactionNotifierType:
                mockTransactionNotifierWithWithdrawTransaction,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('+100.01 AUD'), findsOneWidget);
      });
    });

    testWidgets('should navigate to transaction details page on tap',
        (tester) async {
      await tester.pumpWidget(
        transactionTileTestWidget(
          mockTransactionNotifierType:
              mockTransactionNotifierWithSendTransaction,
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'AUD → BTC'));

      await tester.pumpAndSettle();
      expect(find.byType(TransactionDetailsPage), findsOneWidget);
    });
  });
}

sealed class MockTransactionNotifierType {
  const MockTransactionNotifierType();
}

class MockTransactionNotifierWithData extends MockTransactionNotifierType {
  const MockTransactionNotifierWithData({required this.transactionType});

  final TransactionType transactionType;
}

class MockTransactionNotifierWithNullData extends MockTransactionNotifierType {
  const MockTransactionNotifierWithNullData();
}

class MockTransactionNotifierWithError extends MockTransactionNotifierType {
  const MockTransactionNotifierWithError();
}
