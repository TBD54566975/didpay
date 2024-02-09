import 'package:flutter/material.dart';
import 'package:flutter_starter/features/currency/currency_converter.dart';
import 'package:flutter_starter/shared/animations/invalid_number_pad_input_animation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  group('CurrencyConverter', () {
    testWidgets('should show transaction input and output amounts',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
            child: const CurrencyConverter(
          inputAmount: 1,
          outputSelectedCurrency: 'MXN',
          inputLabel: 'You withdraw',
          outputAmount: 17,
          isValidKeyPress: true,
        )),
      );
      final depositAmountPattern = RegExp(r'\$[0-9]+\.[0-9]{2}$');

      expect(find.textContaining(depositAmountPattern), findsExactly(2));
      expect(find.textContaining('1.00'), findsOneWidget);
      expect(find.textContaining('17.00'), findsOneWidget);
    });

    testWidgets('should show you input and output currencies', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
            child: const CurrencyConverter(
          inputAmount: 1,
          outputSelectedCurrency: 'MXN',
          inputLabel: 'You withdraw',
          outputAmount: 17,
          isValidKeyPress: true,
        )),
      );

      expect(find.textContaining('USD'), findsOneWidget);
      expect(find.textContaining('MXN'), findsOneWidget);
    });

    testWidgets('should show you input label', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
            child: const CurrencyConverter(
          inputAmount: 1,
          outputSelectedCurrency: 'MXN',
          inputLabel: 'You withdraw',
          outputAmount: 17,
          isValidKeyPress: true,
        )),
      );

      expect(find.text('You withdraw'), findsOneWidget);
    });

    testWidgets('should show the `You get` label', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
            child: const CurrencyConverter(
          inputAmount: 1,
          outputSelectedCurrency: 'MXN',
          inputLabel: 'You withdraw',
          outputAmount: 17,
          isValidKeyPress: true,
        )),
      );

      expect(find.text('You get'), findsOneWidget);
    });

    testWidgets('should show the animation component', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
            child: const CurrencyConverter(
          inputAmount: 1,
          outputSelectedCurrency: 'MXN',
          inputLabel: 'You withdraw',
          outputAmount: 17,
          isValidKeyPress: true,
        )),
      );

      expect(find.byType(InvalidNumberPadInputAnimation), findsOneWidget);
    });

    testWidgets(
        'should show one toggle icon if transactionType is deposit or withdrawal',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
            child: const CurrencyConverter(
          inputAmount: 1,
          outputSelectedCurrency: 'MXN',
          inputLabel: 'You withdraw',
          outputAmount: 17,
          isValidKeyPress: true,
        )),
      );

      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    testWidgets('should not show toggle icon if transactionType is not defined',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
            child: const CurrencyConverter(
          inputAmount: 1,
          outputSelectedCurrency: 'MXN',
          inputLabel: 'You withdraw',
          outputAmount: 17,
          isValidKeyPress: true,
        )),
      );

      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });
  });
}
