import 'package:didpay/features/countries/country.dart';
import 'package:didpay/features/pfis/pfi.dart';

class Config {
  static const _countryToPfiMap = {
    _us: _tbdPfi,
    _mx: _tbdPfi,
  };

  static const _us = Country(name: 'United States', code: 'US');
  static const _mx = Country(name: 'Mexico', code: 'MX');

  static const _tbdPfi = Pfi(
    id: '1',
    name: 'TBD PFI',
    // didUri: 'did:web:localhost%3A8892:ingress',
    didUri: 'did:web:192.168.50.27%3A8892:ingress',
  );

  static List<Country> devCountries = [_us, _mx];
  static List<Pfi> devPfis = [_tbdPfi];

  static const pfisJsonUrl =
      'https://raw.githubusercontent.com/TBD54566975/pfi-providers-data/main/pfis.json';

  // feature flags
  static bool get hasWalletPicker => false;

  static Pfi? getPfi(Country? country) => _countryToPfiMap[country];
}
