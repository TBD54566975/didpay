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
              status: TransactionStatus.completed,
              type: TransactionType.withdraw,
            ),
          ),
        ),
      );

      expect(find.text('Withdraw'), findsOneWidget);
    });

    testWidgets('should show transaction amount', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(
              payinAmount: 0,
              payoutAmount: 123,
              payinCurrency: 'USDC',
              payoutCurrency: 'USDC',
              status: TransactionStatus.completed,
              type: TransactionType.deposit,
            ),
          ),
        ),
      );

      expect(find.text('123'), findsOneWidget);
      expect(find.text('USDC'), findsOneWidget);
    });

    testWidgets('should show quoted transaction status', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(
              payinAmount: 0,
              payoutAmount: 123,
              payinCurrency: 'USDC',
              payoutCurrency: 'USDC',
              status: TransactionStatus.pending,
              type: TransactionType.deposit,
            ),
          ),
        ),
      );

      expect(find.text('Quoted'), findsOneWidget);
      expect(find.byIcon(Icons.pending), findsOneWidget);
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
              status: TransactionStatus.completed,
              type: TransactionType.deposit,
            ),
          ),
        ),
      );

      expect(find.text('Completed'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
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
              status: TransactionStatus.failed,
              type: TransactionType.deposit,
            ),
          ),
        ),
      );

      expect(find.text('Failed'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('should show you pay label', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(
              payinAmount: 0,
              payoutAmount: 123,
              payinCurrency: 'USDC',
              payoutCurrency: 'USDC',
              status: TransactionStatus.pending,
              type: TransactionType.deposit,
            ),
          ),
        ),
      );

      expect(find.text('You pay'), findsOneWidget);
    });

    testWidgets('should show you paid label', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(
              payinAmount: 0,
              payoutAmount: 123,
              payinCurrency: 'USDC',
              payoutCurrency: 'USDC',
              status: TransactionStatus.completed,
              type: TransactionType.deposit,
            ),
          ),
        ),
      );

      expect(find.text('You paid'), findsOneWidget);
    });

    testWidgets('should show you received label', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(
              payinAmount: 0,
              payoutAmount: 123,
              payinCurrency: 'USDC',
              payoutCurrency: 'USDC',
              status: TransactionStatus.completed,
              type: TransactionType.withdraw,
            ),
          ),
        ),
      );

      expect(find.text('You received'), findsOneWidget);
    });

    testWidgets('should show account balance label', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(
              payinAmount: 0,
              payoutAmount: 123,
              payinCurrency: 'USDC',
              payoutCurrency: 'USDC',
              status: TransactionStatus.completed,
              type: TransactionType.deposit,
            ),
          ),
        ),
      );

      expect(find.text('Account balance'), findsOneWidget);
    });

    testWidgets('should show reject and accept', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(
              payinAmount: 0,
              payoutAmount: 123,
              payinCurrency: 'USDC',
              payoutCurrency: 'USDC',
              status: TransactionStatus.pending,
              type: TransactionType.deposit,
            ),
          ),
        ),
      );

      expect(find.text('Reject'), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);
    });

    testWidgets('should show done', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(
              payinAmount: 0,
              payoutAmount: 123,
              payinCurrency: 'USDC',
              payoutCurrency: 'USDC',
              status: TransactionStatus.completed,
              type: TransactionType.deposit,
            ),
          ),
        ),
      );

      expect(find.text('Done'), findsOneWidget);
    });
  });
}
