import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/features/home/transaction_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  group('TransactionDetailsPage', () {
    testWidgets('should show deposit header', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(
              payinAmount: 0,
              payoutAmount: 0,
              payinCurrency: 'USDC',
              payoutCurrency: 'USDC',
              createdAt: DateTime.now(),
              status: TransactionStatus.completed,
              type: TransactionType.deposit,
            ),
          ),
        ),
      );

      expect(find.text('Deposit'), findsOneWidget);
    });

    testWidgets('should show withdraw header', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(
              payinAmount: 0,
              payoutAmount: 0,
              payinCurrency: 'USDC',
              payoutCurrency: 'USDC',
              createdAt: DateTime.now(),
              status: TransactionStatus.completed,
              type: TransactionType.withdraw,
            ),
          ),
        ),
      );

      expect(find.text('Withdraw'), findsOneWidget);
    });

    testWidgets('should show transaction amounts', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(
              payinAmount: 654,
              payoutAmount: 123,
              payinCurrency: 'USDC',
              payoutCurrency: 'MXN',
              createdAt: DateTime.now(),
              status: TransactionStatus.completed,
              type: TransactionType.deposit,
            ),
          ),
        ),
      );

      expect(find.text('654'), findsOneWidget);
      expect(find.text('123'), findsOneWidget);
      expect(find.text('MXN'), findsOneWidget);
      expect(find.text('USDC'), findsOneWidget);
    });

    testWidgets('should show pending transaction status', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(
              payinAmount: 0,
              payoutAmount: 123,
              payinCurrency: 'USDC',
              payoutCurrency: 'USDC',
              createdAt: DateTime.now(),
              status: TransactionStatus.pending,
              type: TransactionType.deposit,
            ),
          ),
        ),
      );

      expect(find.widgetWithText(OutlinedButton, 'Pending'), findsOneWidget);
    });

    testWidgets('should show completed transaction status', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(
              payinAmount: 0,
              payoutAmount: 123,
              payinCurrency: 'USDC',
              payoutCurrency: 'USDC',
              createdAt: DateTime.now(),
              status: TransactionStatus.completed,
              type: TransactionType.deposit,
            ),
          ),
        ),
      );

      expect(find.widgetWithText(OutlinedButton, 'Completed'), findsOneWidget);
    });

    testWidgets('should show failed transaction status', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(
              payinAmount: 0,
              payoutAmount: 123,
              payinCurrency: 'USDC',
              payoutCurrency: 'USDC',
              createdAt: DateTime.now(),
              status: TransactionStatus.failed,
              type: TransactionType.deposit,
            ),
          ),
        ),
      );

      expect(find.widgetWithText(OutlinedButton, 'Failed'), findsOneWidget);
    });
  });
}
