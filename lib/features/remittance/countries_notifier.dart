import 'dart:async';
import 'dart:convert';

import 'package:didpay/features/remittance/countries.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final countriesProvider =
    StateNotifierProvider<CountriesNotifier, List<Country>>(
  (ref) => throw UnimplementedError(),
);

class CountriesNotifier extends StateNotifier<List<Country>> {
  static const String prefsKey = 'countries';
  final SharedPreferences prefs;

  CountriesNotifier(this.prefs, super.state);

  Future<Country> add(String code, String name) async {
    final country = Country(code: code, name: name);

    state = [...state, country];
    await _save();
    return country;
  }

  Future<void> remove(Country country) async {
    state = state.where((elem) => elem.code != country.code).toList();
    await _save();
  }

  Future<void> _save() async {
    final toSave = state.map((e) => e.code).toList();
    await prefs.setStringList('countries', toSave);
  }

  Future<List<Country>> loadSavedCountryCodes() async {
    final saved = prefs.getStringList(prefsKey);

    if (saved == null) {
      return [];
    }
    final countries = <Country>[];
    for (final country in saved) {
      try {
        countries.add(Country.fromJson(jsonDecode(country)));
      } on Exception catch (e) {
        throw Exception('Failed to load saved country: $e');
      }
    }

    return countries;
  }
}
