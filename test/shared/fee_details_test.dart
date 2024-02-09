import 'package:flutter_starter/shared/fee_details.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/widget_helpers.dart';

void main() {
  group('FeeDetails', () {
    testWidgets('should show input text strings', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const FeeDetails(
            originCurrency: 'USD',
            destinationCurrency: 'MXN',
            exchangeRate: '17',
            serviceFee: '0',
          ),
        ),
      );

      expect(find.text('1 USD = 17 MXN'), findsOneWidget);
      expect(find.text('0 MXN'), findsOneWidget);
    });

    testWidgets('should show est rate', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
            child: const FeeDetails(
          originCurrency: 'USD',
          destinationCurrency: 'MXN',
          exchangeRate: '17',
          serviceFee: '0',
        )),
      );

      expect(find.text('Est. rate'), findsOneWidget);
    });

    testWidgets('should show exchange rate', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
            child: const FeeDetails(
          originCurrency: 'USD',
          destinationCurrency: 'MXN',
          exchangeRate: '17',
          serviceFee: '0',
        )),
      );
      final exchangeRatePattern = RegExp(r'1 [A-Z]{3} = \d+ [A-Z]{3}');

      expect(find.textContaining(exchangeRatePattern), findsOneWidget);
    });

    testWidgets('should show service fee', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
            child: const FeeDetails(
          originCurrency: 'USD',
          destinationCurrency: 'MXN',
          exchangeRate: '17',
          serviceFee: '0',
        )),
      );

      expect(find.text('Service fee'), findsOneWidget);
    });
  });
}
