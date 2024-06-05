import 'package:didpay/features/payin/payin.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/shared/shake_animated_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbdex/tbdex.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  group('Payin', () {
    final amount = ValueNotifier<String>('70');
    final pfi = ValueNotifier<Pfi?>(null);
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
    final keyPress = ValueNotifier<PayinKeyPress>(PayinKeyPress(0, ''));

    final paymentState = PaymentState(
      transactionType: TransactionType.deposit,
      selectedOffering: offering.value,
      selectedPfi: pfi.value,
      offeringsMap: const {},
    );

    Widget payinTestWidget({PaymentState? paymentStateOverride}) =>
        WidgetHelpers.testableWidget(
          child: Payin(
            paymentState: paymentStateOverride ?? paymentState,
            payinAmount: amount,
            keyPress: keyPress,
            onCurrencySelect: (_, __) {},
          ),
        );

    testWidgets('should show payin amount', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: payinTestWidget()),
      );

      expect(find.textContaining('70'), findsOneWidget);
    });

    testWidgets('should show you payin currency', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: payinTestWidget()),
      );

      expect(find.textContaining('AUD'), findsOneWidget);
    });

    testWidgets('should show pay label', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: payinTestWidget()),
      );

      expect(find.text('You pay'), findsOneWidget);
    });

    testWidgets('should show withdraw label', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: payinTestWidget(
            paymentStateOverride: paymentState.copyWith(
              transactionType: TransactionType.withdraw,
            ),
          ),
        ),
      );

      expect(find.text('You withdraw'), findsOneWidget);
    });

    testWidgets('should show the animation widget', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: payinTestWidget()),
      );

      expect(find.byType(ShakeAnimatedWidget), findsOneWidget);
    });

    testWidgets('should show toggle icon for deposit transaction type',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: payinTestWidget()),
      );

      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    testWidgets('should not show toggle icon for withdraw transaction type',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: payinTestWidget(
            paymentStateOverride: paymentState.copyWith(
              transactionType: TransactionType.withdraw,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
    });
  });
}
