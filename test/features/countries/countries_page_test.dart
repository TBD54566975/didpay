import 'package:didpay/features/countries/countries.dart';
import 'package:didpay/features/countries/countries_notifier.dart';
import 'package:didpay/features/countries/countries_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/mocks.dart';
import '../../helpers/widget_helpers.dart';

void main() {
  Widget testableWidget({List<Country> initialCountries = const []}) {
    final countriesNotifier = MockCountriesNotifier(initialCountries);

    return WidgetHelpers.testableWidget(
      child: const CountriesPage(),
      overrides: [
        countriesProvider.overrideWith((ref) => countriesNotifier),
      ],
    );
  }

  group('CountriesPage', () {
    testWidgets('should show countries', (tester) async {
      await tester.pumpWidget(
        testableWidget(
          initialCountries: const [
            Country(name: 'Mexico', code: 'MXN'),
            Country(name: 'United States', code: 'USD'),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mexico'), findsOneWidget);
      expect(find.text('United States'), findsOneWidget);
    });
  });
}
