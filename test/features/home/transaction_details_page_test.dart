import 'package:flutter/material.dart';
import 'package:didpay/features/home/transaction_details_page.dart';
import 'package:didpay/features/home/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  group('TransactionDetailsPage', () {
    testWidgets('should show deposit header', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(type: 'Deposit', status: '', amount: 0),
          ),
        ),
      );

      expect(find.text('Deposit'), findsOneWidget);
    });

    testWidgets('should show withdrawal header', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(type: 'Withdrawal', status: '', amount: 0),
          ),
        ),
      );

      expect(find.text('Withdrawal'), findsOneWidget);
    });

    testWidgets('should show transaction amount', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(type: '', status: '', amount: 123.45),
          ),
        ),
      );

      expect(find.text('123.45 USD'), findsExactly(3));
    });

    testWidgets('should show quoted transaction status', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(type: '', status: 'Quoted', amount: 0),
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
            txn: Transaction(type: '', status: 'Completed', amount: 0),
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
            txn: Transaction(type: '', status: 'Failed', amount: 0),
          ),
        ),
      );

      expect(find.text('Failed'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('should show unknown transaction status', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(type: '', status: 'Unknown', amount: 0),
          ),
        ),
      );

      expect(find.text('Unknown'), findsOneWidget);
      expect(find.byIcon(Icons.help), findsOneWidget);
    });

    testWidgets('should show you pay label', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(type: '', status: 'Quoted', amount: 0),
          ),
        ),
      );

      expect(find.text('You pay'), findsOneWidget);
    });

    testWidgets('should show you paid label', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(type: 'Deposit', status: 'Completed', amount: 0),
          ),
        ),
      );

      expect(find.text('You paid'), findsOneWidget);
    });

    testWidgets('should show you received label', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn:
                Transaction(type: 'Withdrawal', status: 'Completed', amount: 0),
          ),
        ),
      );

      expect(find.text('You received'), findsOneWidget);
    });

    testWidgets('should show account balance label', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(type: '', status: 'Completed', amount: 0),
          ),
        ),
      );

      expect(find.text('Account balance'), findsOneWidget);
    });

    testWidgets('should show reject and accept', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(type: '', status: 'Quoted', amount: 0),
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
            txn: Transaction(type: '', status: 'Completed', amount: 0),
          ),
        ),
      );

      expect(find.text('Done'), findsOneWidget);
    });
  });
}
