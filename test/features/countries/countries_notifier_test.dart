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
          .thenReturn(initialCountries);

      final notifier = await CountriesNotifier.create(mockBox);

      expect(notifier.state, initialCountries);
      verify(() => mockBox.get(CountriesNotifier.storageKey)).called(1);
    });

    test('should add a new Country', () async {
      final initialCountries = [const Country(name: 'Mexico', code: 'MXN')];
      const newCountry = Country(name: 'United States', code: 'USD');

      when(() => mockBox.get(CountriesNotifier.storageKey))
          .thenReturn(initialCountries);
      when(() => mockBox.put(CountriesNotifier.storageKey, any()))
          .thenAnswer((_) async {});

      final notifier = await CountriesNotifier.create(mockBox);

      final addedCountry = await notifier.add(newCountry.code, newCountry.name);

      expect(notifier.state, [...initialCountries, newCountry]);
      expect(addedCountry, newCountry);

      verify(
        () => mockBox.put(
          CountriesNotifier.storageKey,
          [...initialCountries, newCountry],
        ),
      ).called(1);
    });

    test('should remove a Country', () async {
      final initialCountries = [const Country(name: 'Mexico', code: 'MXN')];
      final countryToRemove = initialCountries.first;

      when(() => mockBox.get(CountriesNotifier.storageKey))
          .thenReturn(initialCountries);
      when(() => mockBox.put(CountriesNotifier.storageKey, any()))
          .thenAnswer((_) async {});

      final notifier = await CountriesNotifier.create(mockBox);
      await notifier.remove(countryToRemove);

      expect(notifier.state, []);
      verify(() => mockBox.put(CountriesNotifier.storageKey, [])).called(1);
    });
  });
}
