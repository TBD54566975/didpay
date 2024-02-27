import 'package:didpay/features/pfis/pfi.dart';

class Config {
  static List<Pfi> devPfis = [
    Pfi(
      id: '1',
      name: 'TBD PFI',
      didUri: 'did:web:localhost%3A8892:ingress',
    ),
  ];
  static const pfisJsonUrl =
      'https://raw.githubusercontent.com/TBD54566975/pfi-providers-data/main/pfis.json';
}
