import 'package:didpay/features/countries/countries.dart';
import 'package:didpay/features/countries/countries_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockBox mockBox;

  setUp(() {
    mockBox = MockBox();
  });

  group('CountriesNotifier', () {
    test('should create and load initial list', () async {
      final initialCountries = [const Country(name: 'Mexico', code: 'MXN')];

      when(() => mockBox.get(CountriesNotifier.storageKey))
          .thenReturn(initialCountries.map((pfi) => pfi.toJson()).toList());
      final notifier = await CountriesNotifier.create(mockBox);

      expect(notifier.state, initialCountries);
      verify(() => mockBox.get(CountriesNotifier.storageKey)).called(1);
    });

    test('should add a new Country', () async {
      final initialCountries = [const Country(name: 'Mexico', code: 'MXN')];
      const newCountry = Country(name: 'United States', code: 'USD');

      when(() => mockBox.get(CountriesNotifier.storageKey))
          .thenReturn(initialCountries.map((pfi) => pfi.toJson()).toList());
      when(
        () => mockBox.put(
          CountriesNotifier.storageKey,
          any<List<Map<String, dynamic>>>(),
        ),
      ).thenAnswer((_) async {});

      final notifier = await CountriesNotifier.create(mockBox);

      final addedCountry = await notifier.add(newCountry.code, newCountry.name);

      expect(notifier.state, [...initialCountries, newCountry]);
      expect(addedCountry, newCountry);

      verify(
        () => mockBox.put(
          CountriesNotifier.storageKey,
          [
            ...initialCountries.map((country) => country.toJson()),
            newCountry.toJson(),
          ],
        ),
      ).called(1);
    });

    test('should remove a Country', () async {
      final initialCountries = [const Country(name: 'Mexico', code: 'MXN')];
      final countryToRemove = initialCountries.first;

      when(() => mockBox.get(CountriesNotifier.storageKey))
          .thenReturn(initialCountries.map((pfi) => pfi.toJson()).toList());
      when(() => mockBox.put(CountriesNotifier.storageKey, any()))
          .thenAnswer((_) async {});

      final notifier = await CountriesNotifier.create(mockBox);
      await notifier.remove(countryToRemove);

      expect(notifier.state, []);
      verify(() => mockBox.put(CountriesNotifier.storageKey, [])).called(1);
    });
  });
}
