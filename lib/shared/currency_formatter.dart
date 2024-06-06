import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:decimal/intl.dart';
import 'package:intl/intl.dart';

extension CurrencyFormatter on Decimal {
  String formatCurrency(
    String currencyCode,
  ) =>
      NumberFormat.currency(
        symbol: '',
        decimalDigits: min(scale, currencyCode == 'BTC' ? 8 : 2),
      ).format(DecimalIntl(this));
}
