import 'package:didpay/features/payout/payout.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbdex/tbdex.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  group('Payout', () {
    final amount = ValueNotifier<double>(2);
    final offering = ValueNotifier<Offering?>(
      Offering.create(
        'pfiDid',
        OfferingData(
          description: '',
          payoutUnitsPerPayinUnit: '1',
          payin: PayinDetails(
            currencyCode: 'AUD',
            min: '0.01',
            max: '100.00',
            methods: [
              PayinMethod(
                kind: 'DEBIT_CARD',
              ),
            ],
          ),
          payout: PayoutDetails(
            currencyCode: 'USDC',
            methods: [
              PayoutMethod(
                estimatedSettlementTime: 0,
                kind: 'DEBIT_CARD',
              ),
            ],
          ),
        ),
      ),
    );

    testWidgets('should show payout amount', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: Payout(
            payoutAmount: amount,
            selectedOffering: offering,
            transactionType: TransactionType.deposit,
            payinAmount: 34,
            offerings: const [],
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
            selectedOffering: offering,
            transactionType: TransactionType.deposit,
            payinAmount: 0,
            offerings: const [],
          ),
        ),
      );

      expect(find.textContaining('USDC'), findsOneWidget);
    });

    testWidgets('should show the `You get` label', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: Payout(
            payoutAmount: amount,
            selectedOffering: offering,
            transactionType: TransactionType.withdraw,
            payinAmount: 0,
            offerings: const [],
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
            selectedOffering: offering,
            transactionType: TransactionType.withdraw,
            payinAmount: 0,
            offerings: const [],
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
            selectedOffering: offering,
            transactionType: TransactionType.deposit,
            payinAmount: 0,
            offerings: const [],
          ),
        ),
      );

      expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
    });
  });
}
