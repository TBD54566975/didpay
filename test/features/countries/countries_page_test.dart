import 'package:didpay/features/countries/countries_notifier.dart';
import 'package:didpay/features/countries/countries_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';
import '../../helpers/widget_helpers.dart';

void main() {
  final australia = TestData.getCountry('Australia', 'AU');
  final us = TestData.getCountry('United States', 'US');
  final initialCountries = [australia, us];

  group('CountriesPage', () {
    Widget countriesPageTestWidget() {
      final countriesNotifier = MockCountriesNotifier(initialCountries);

      return WidgetHelpers.testableWidget(
        child: const CountriesPage(),
        overrides: [
          countriesProvider.overrideWith((ref) => countriesNotifier),
        ],
      );
    }

    testWidgets('should show countries', (tester) async {
      await tester.pumpWidget(countriesPageTestWidget());

      await tester.pumpAndSettle();

      expect(find.text('Australia'), findsOneWidget);
      expect(find.text('United States'), findsOneWidget);
    });
  });
}
