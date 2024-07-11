import 'package:didpay/features/payin/payin.dart';
import 'package:didpay/features/payment/payment_amount_state.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/shared/number/number_key_press.dart';
import 'package:didpay/shared/shake_animated_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data.dart';
import '../../helpers/widget_helpers.dart';

void main() async {
  await TestData.initializeDids();

  group('Payin', () {
    final offering = TestData.getOffering();
    final keyPress = ValueNotifier<NumberKeyPress>(NumberKeyPress(0, ''));

    final paymentState = PaymentAmountState(
      payinAmount: '70',
      selectedOffering: offering,
      offeringsMap: const {},
    );

    Widget payinTestWidget({TransactionType? transactionTypeOverride}) =>
        WidgetHelpers.testableWidget(
          child: Payin(
            transactionType: transactionTypeOverride ?? TransactionType.deposit,
            state: ValueNotifier(paymentState),
            keyPress: keyPress,
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
            transactionTypeOverride: TransactionType.withdraw,
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
            transactionTypeOverride: TransactionType.withdraw,
          ),
        ),
      );

      expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
    });
  });
}
