import 'dart:async';

import 'package:didpay/features/countries/countries.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final countriesProvider =
    StateNotifierProvider<CountriesNotifier, List<Country>>(
  (ref) => throw UnimplementedError(),
);

class CountriesNotifier extends StateNotifier<List<Country>> {
  static const String storageKey = 'countries';
  final Box box;

  CountriesNotifier._(this.box, List<Country> state) : super(state);

  static Future<CountriesNotifier> create(Box box) async {
    final List<dynamic> countriesJson = await box.get(storageKey) ?? [];
    final countries = countriesJson
        .map((json) => Country.fromJson(Map<String, dynamic>.from(json)))
        .toList();
    return CountriesNotifier._(box, countries);
  }

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
    final countries = state.map((country) => country.toJson()).toList();
    await box.put(storageKey, countries);
  }
}
