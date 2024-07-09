import 'package:decimal/decimal.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/payout/payout.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbdex/tbdex.dart';

import '../../helpers/test_data.dart';
import '../../helpers/widget_helpers.dart';

void main() async {
  await TestData.initializeDids();
  group('Payout', () {
    final amount = ValueNotifier<Decimal>(Decimal.one);
    final pfi = ValueNotifier<Pfi?>(null);
    final offering = ValueNotifier<Offering?>(TestData.getOffering());

    final paymentState = PaymentState(
      transactionType: TransactionType.deposit,
      offering: offering.value,
      pfi: pfi.value,
      offeringsMap: const {},
    );

    Widget payoutTestWidget({PaymentState? paymentStateOverride}) =>
        WidgetHelpers.testableWidget(
          child: Payout(
            paymentState: paymentStateOverride ?? paymentState,
            payoutAmount: amount,
            onCurrencySelect: (_, __) {},
          ),
        );

    testWidgets('should show payout amount', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: payoutTestWidget()),
      );

      expect(find.textContaining('1'), findsOneWidget);
    });

    testWidgets('should show you payout currency', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: payoutTestWidget()),
      );

      expect(find.textContaining('USD'), findsOneWidget);
    });

    testWidgets('should show the `You get` label', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: payoutTestWidget(
            paymentStateOverride: paymentState.copyWith(
              transactionType: TransactionType.withdraw,
            ),
          ),
        ),
      );

      expect(find.text('You get'), findsOneWidget);
    });

    testWidgets('should show toggle icon for withdraw transaction type',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: payoutTestWidget(
            paymentStateOverride: paymentState.copyWith(
              transactionType: TransactionType.withdraw,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    testWidgets('should not show toggle icon for deposit transaction type',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: payoutTestWidget()),
      );

      expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
    });
  });
}
