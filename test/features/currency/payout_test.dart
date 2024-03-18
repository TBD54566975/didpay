import 'package:didpay/features/currency/currency.dart';
import 'package:didpay/features/currency/payout.dart';
import 'package:didpay/features/home/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  group('Payout', () {
    final amount = ValueNotifier<double>(2);
    final currency = ValueNotifier<Currency?>(
      Currency(exchangeRate: 17, code: CurrencyCode.mxn, icon: Icons.abc),
    );

    testWidgets('should show payout amount', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: Payout(
            payoutAmount: amount,
            currency: currency,
            transactionType: TransactionType.deposit,
            payinAmount: 34,
          ),
        ),
      );

      expect(find.textContaining('2'), findsOneWidget);
    });

    testWidgets('should show you payout currency', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: Payout(
            payoutAmount: amount,
            currency: currency,
            transactionType: TransactionType.deposit,
            payinAmount: 0,
          ),
        ),
      );

      expect(find.textContaining('USD'), findsOneWidget);
    });

    testWidgets('should show the `You get` label', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: Payout(
            payoutAmount: amount,
            currency: currency,
            transactionType: TransactionType.deposit,
            payinAmount: 0,
          ),
        ),
      );

      expect(find.text('You get'), findsOneWidget);
    });

    testWidgets('should show toggle icon for withdraw transaction type',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: Payout(
            payoutAmount: amount,
            currency: currency,
            transactionType: TransactionType.withdraw,
            payinAmount: 0,
          ),
        ),
      );

      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    testWidgets('should not show toggle icon for deposit transaction type',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: Payout(
            payoutAmount: amount,
            currency: currency,
            transactionType: TransactionType.deposit,
            payinAmount: 0,
          ),
        ),
      );

      expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
    });
  });
}
