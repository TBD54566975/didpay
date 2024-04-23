import 'package:didpay/features/countries/country.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web5/web5.dart';

final didProvider = Provider<BearerDid>((ref) => throw UnimplementedError());
final vcProvider = StateProvider<String?>((ref) => null);
final countryProvider = StateProvider<Country?>((ref) => null);
