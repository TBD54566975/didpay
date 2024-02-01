import 'package:flutter_starter/shared/currency_converter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/widget_helpers.dart';

void main() {
  group('CurrencyConverter', () {
    testWidgets('should show transaction input and output amounts',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
            child: const CurrencyConverter(
          originAmount: '1.00',
          originCurrency: 'USD',
          originLabel: 'You withdraw',
          destinationCurrency: 'MXN',
          exchangeRate: '17',
          isValidKeyPress: true,
        )),
      );
      final depositAmountPattern = RegExp(r'\$[0-9]+\.[0-9]{2}$');

      expect(find.textContaining(depositAmountPattern), findsExactly(2));
      expect(find.textContaining('1.00'), findsOneWidget);
      expect(find.textContaining('17.00'), findsOneWidget);
    });

    testWidgets('should show you origin and desination currencies',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
            child: const CurrencyConverter(
          originAmount: '1.00',
          originCurrency: 'USD',
          originLabel: 'You withdraw',
          destinationCurrency: 'MXN',
          exchangeRate: '17',
          isValidKeyPress: true,
        )),
      );

      expect(find.textContaining('USD'), findsOneWidget);
      expect(find.textContaining('MXN'), findsOneWidget);
    });

    testWidgets('should show you origin label', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
            child: const CurrencyConverter(
          originAmount: '1.00',
          originCurrency: 'USD',
          originLabel: 'You withdraw',
          destinationCurrency: 'MXN',
          exchangeRate: '17',
          isValidKeyPress: true,
        )),
      );

      expect(find.text('You withdraw'), findsOneWidget);
    });

    testWidgets('should show you get', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
            child: const CurrencyConverter(
          originAmount: '1.00',
          originCurrency: 'USD',
          originLabel: 'You withdraw',
          destinationCurrency: 'MXN',
          exchangeRate: '17',
          isValidKeyPress: true,
        )),
      );

      expect(find.text('You get'), findsOneWidget);
    });
  });
}
