import 'package:didpay/features/pfis/pfi.dart';
import 'package:tbdex/tbdex.dart';

class AccountBalance {
  final String total;
  final String currencyCode;
  final Map<Pfi, List<Balance>> balancesMap;

  AccountBalance({
    required this.total,
    required this.currencyCode,
    required this.balancesMap,
  });
}
