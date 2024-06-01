import 'package:decimal/decimal.dart';
import 'package:decimal/intl.dart';
import 'package:intl/intl.dart';

extension CurrencyFormatter on Decimal {
  String formatCurrency(String currencyCode, {int hintDigits = 0}) {
    final decimalDigits = this % Decimal.one == Decimal.zero
        ? 0
        : (currencyCode == 'BTC' ? 8 : 2) - hintDigits;
    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: decimalDigits,
    );
    return formatter.format(DecimalIntl(this));
  }
}
