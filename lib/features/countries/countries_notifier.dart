import 'dart:async';
import 'dart:convert';

import 'package:didpay/config/config.dart';
import 'package:didpay/features/countries/country.dart';
import 'package:didpay/features/storage/storage_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

final countriesProvider =
    AsyncNotifierProvider<CountriesAsyncNotifier, List<Country>>(
  CountriesAsyncNotifier.new,
);

class CountriesAsyncNotifier extends AsyncNotifier<List<Country>> {
  final _cacheKey = 'didpay:countries_cache';

  @override
  FutureOr<List<Country>> build() => _loadFromCache();

  void addCountry(Country newCountry) {
    final currentCountries = state.value ?? [];
    final updatedCountries = [...currentCountries, newCountry];
    state = AsyncData(updatedCountries);
  }

  Future<void> reload() async {
    if (Config.devPfis.isNotEmpty) {
      state = AsyncData(Config.devCountries);
      return;
    }

    final countries = await _loadFromCache();
    // Show loading indicator if cache is empty
    state = countries.isEmpty ? const AsyncLoading() : AsyncData(countries);

    final response = await http.get(Uri.parse(Config.pfisJsonUrl));
    if (response.statusCode != 200) {
      state = AsyncError('Failed to load countries', StackTrace.current);
      return;
    }

    await ref
        .read(sharedPreferencesProvider)
        .setString(_cacheKey, response.body);

    state = AsyncData(
      List<Country>.from(
        (json.decode(response.body) as List)
            .map((item) => Country.fromJson(item as Map<String, dynamic>)),
      ),
    );
  }

  Future<List<Country>> _loadFromCache() async {
    final cachedData = ref.read(sharedPreferencesProvider).getString(_cacheKey);
    if (cachedData == null) {
      return [];
    }

    return List<Country>.from(
      (json.decode(cachedData) as List).map(
        (item) => Country.fromJson(item as Map<String, dynamic>),
      ),
    );
  }
}
