import 'package:hooks_riverpod/hooks_riverpod.dart';

class Country {
  final String name;
  final String code;

  Country({
    required this.name,
    required this.code,
  });
}

final _defaultList = [
  Country(name: 'United States', code: 'US'),
  Country(name: 'Mexico', code: 'MX'),
  Country(name: 'Kenya', code: 'KE'),
];

final countryProvider = StateProvider<List<Country>>((ref) {
  return _defaultList;
});
