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
              payinCurrency: 'USD',
              payoutCurrency: 'USD',
              status: TransactionStatus.paymentReceived,
              createdAt: DateTime.now(),
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
              payinCurrency: 'USD',
              payoutCurrency: 'USD',
              status: TransactionStatus.paymentReceived,
              createdAt: DateTime.now(),
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
              payinCurrency: 'USD',
              payoutCurrency: 'MXN',
              status: TransactionStatus.paymentReceived,
              createdAt: DateTime.now(),
              type: TransactionType.deposit,
            ),
          ),
        ),
      );

      expect(find.text('654'), findsOneWidget);
      expect(find.text('123'), findsOneWidget);
      expect(find.text('MXN'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
    });

    testWidgets('should show payment received transaction status',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(
              payinAmount: 0,
              payoutAmount: 123,
              payinCurrency: 'USD',
              payoutCurrency: 'USD',
              status: TransactionStatus.paymentReceived,
              createdAt: DateTime.now(),
              type: TransactionType.deposit,
            ),
          ),
        ),
      );

      expect(
        find.widgetWithText(OutlinedButton, 'Payment received'),
        findsOneWidget,
      );
    });

    testWidgets('should show payment complete transaction status',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(
              payinAmount: 0,
              payoutAmount: 123,
              payinCurrency: 'USD',
              payoutCurrency: 'USD',
              status: TransactionStatus.paymentComplete,
              createdAt: DateTime.now(),
              type: TransactionType.deposit,
            ),
          ),
        ),
      );

      expect(find.widgetWithText(OutlinedButton, 'Payment complete'),
          findsOneWidget,);
    });

    testWidgets('should show payment canceled transaction status',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: TransactionDetailsPage(
            txn: Transaction(
              payinAmount: 0,
              payoutAmount: 123,
              payinCurrency: 'USD',
              payoutCurrency: 'USD',
              status: TransactionStatus.paymentCanceled,
              createdAt: DateTime.now(),
              type: TransactionType.deposit,
            ),
          ),
        ),
      );

      expect(find.widgetWithText(OutlinedButton, 'Payment canceled'),
          findsOneWidget,);
    });
  });
}
