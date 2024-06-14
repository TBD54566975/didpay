import 'package:didpay/features/countries/countries_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  final australia = TestData.getCountry('Australia', 'AU');
  final us = TestData.getCountry('United States', 'US');
  final initialCountries = [australia];

  late MockBox mockBox;

  setUp(() {
    mockBox = MockBox();
  });

  group('CountriesNotifier', () {
    test('should create and load initial list', () async {
      when(() => mockBox.get(CountriesNotifier.storageKey)).thenReturn(
        initialCountries.map((country) => country.toJson()).toList(),
      );
      final notifier = await CountriesNotifier.create(mockBox);

      expect(notifier.state, initialCountries);
      verify(() => mockBox.get(CountriesNotifier.storageKey)).called(1);
    });

    test('should add a new Country', () async {
      when(() => mockBox.get(CountriesNotifier.storageKey)).thenReturn(
        initialCountries.map((country) => country.toJson()).toList(),
      );
      when(
        () => mockBox.put(
          CountriesNotifier.storageKey,
          any<List<Map<String, dynamic>>>(),
        ),
      ).thenAnswer((_) async {});

      final notifier = await CountriesNotifier.create(mockBox);

      final addedCountry = await notifier.add(us);

      expect(notifier.state, [...initialCountries, us]);
      expect(addedCountry, us);

      verify(
        () => mockBox.put(
          CountriesNotifier.storageKey,
          [
            ...initialCountries.map((country) => country.toJson()),
            us.toJson(),
          ],
        ),
      ).called(1);
    });

    test('should remove a Country', () async {
      final countryToRemove = initialCountries.first;

      when(() => mockBox.get(CountriesNotifier.storageKey)).thenReturn(
        initialCountries.map((country) => country.toJson()).toList(),
      );
      when(() => mockBox.put(CountriesNotifier.storageKey, any()))
          .thenAnswer((_) async {});

      final notifier = await CountriesNotifier.create(mockBox);
      await notifier.remove(countryToRemove);

      expect(notifier.state, []);
      verify(() => mockBox.put(CountriesNotifier.storageKey, [])).called(1);
    });
  });
}
