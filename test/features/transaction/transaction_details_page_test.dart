import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/features/transaction/transaction_details_page.dart';
import 'package:didpay/features/transaction/transaction_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';
import '../../helpers/widget_helpers.dart';

void main() {
  group('TransactionDetailsPage', () {
    final sendTransaction = TestData.getTransaction();
    final depositTransaction =
        TestData.getTransaction(type: TransactionType.deposit);
    final withdrawTransaction =
        TestData.getTransaction(type: TransactionType.withdraw);

    const mockTransactionNotifierWithSendTransaction =
        MockTransactionNotifierWithData(
      transactionType: TransactionType.send,
    );
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

    Widget transactionDetailsTestWidget({
      required MockTransactionNotifierType mockTransactionNotifierType,
    }) =>
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            pfi: TestData.getPfi('did:dht:pfiDid'),
            exchangeId: 'rfq_01ha835rhefwmagsknrrhvaa0k',
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

    testWidgets('should show correct payout and payin amounts', (tester) async {
      await tester.pumpWidget(
        transactionDetailsTestWidget(
          mockTransactionNotifierType:
              mockTransactionNotifierWithSendTransaction,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('100.01'),
        findsOneWidget,
      );
    });

    testWidgets('should show transaction date', (tester) async {
      await tester.pumpWidget(
        transactionDetailsTestWidget(
          mockTransactionNotifierType:
              mockTransactionNotifierWithSendTransaction,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          DateFormat("MMM dd 'at' hh:mm a")
              .format(sendTransaction.createdAt.toLocal()),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should show transaction status chip', (tester) async {
      await tester.pumpWidget(
        transactionDetailsTestWidget(
          mockTransactionNotifierType:
              mockTransactionNotifierWithSendTransaction,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Order submitted'),
        findsOneWidget,
      );
    });

    testWidgets('should display error when transaction fetch fails',
        (tester) async {
      await tester.pumpWidget(
        transactionDetailsTestWidget(
          mockTransactionNotifierType: mockTransactionNotifierWithError,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bad state: Error loading transaction'), findsOneWidget);
    });
  });
}

