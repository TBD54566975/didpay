import 'package:didpay/features/currency/currency.dart';
import 'package:didpay/features/currency/payin.dart';
import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/shared/shake_animated_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  group('Payin', () {
    final amount = ValueNotifier<String>('70');
    final currency = ValueNotifier<Currency?>(
      Currency(exchangeRate: 17, code: CurrencyCode.mxn, icon: Icons.abc),
    );
    final keyPress = ValueNotifier<PayinKeyPress>(PayinKeyPress(0, ''));

    testWidgets('should show payin amount', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: Payin(
            transactionType: TransactionType.deposit,
            amount: amount,
            keyPress: keyPress,
            currency: currency,
          ),
        ),
      );

      expect(find.textContaining('70'), findsOneWidget);
    });

    testWidgets('should show you payin currency', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: Payin(
            transactionType: TransactionType.deposit,
            amount: amount,
            keyPress: keyPress,
            currency: currency,
          ),
        ),
      );

      expect(find.textContaining('MXN'), findsOneWidget);
    });

    testWidgets('should show deposit label', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: Payin(
            transactionType: TransactionType.deposit,
            amount: amount,
            keyPress: keyPress,
            currency: currency,
          ),
        ),
      );

      expect(find.text('You deposit'), findsOneWidget);
    });

    testWidgets('should show withdraw label', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: Payin(
            transactionType: TransactionType.withdraw,
            amount: amount,
            keyPress: keyPress,
            currency: currency,
          ),
        ),
      );

      expect(find.text('You withdraw'), findsOneWidget);
    });

    testWidgets('should show the animation widget', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: Payin(
            transactionType: TransactionType.deposit,
            amount: amount,
            keyPress: keyPress,
            currency: currency,
          ),
        ),
      );

      expect(find.byType(ShakeAnimatedWidget), findsOneWidget);
    });

    testWidgets('should show toggle icon for deposit transaction type',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: Payin(
            transactionType: TransactionType.deposit,
            amount: amount,
            keyPress: keyPress,
            currency: currency,
          ),
        ),
      );

      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    testWidgets('should not show toggle icon for withdraw transaction type',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: Payin(
            transactionType: TransactionType.withdraw,
            amount: amount,
            keyPress: keyPress,
            currency: currency,
          ),
        ),
      );

      expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
    });
  });
}
