import 'package:intl/intl.dart';

class CurrencyUtil {
  const CurrencyUtil._();

  static int getDecimalDigits(String? currency) {
    return currency == 'BTC' ? 8 : 2;
  }

  static String formatFromString(
    String amount, {
    String? currency,
  }) {
    final decimalDigits =
        amount.contains('.') ? amount.split('.')[1].length : 0;
    final parsedAmount = double.tryParse(amount) ?? 0.0;
    return formatFromDouble(
      parsedAmount,
      currency: currency,
      decimalDigits: decimalDigits,
    );
  }

  static String formatFromDouble(
    double amount, {
    String? currency,
    int? decimalDigits,
  }) {
    final currencyDecimalDigits = CurrencyUtil.getDecimalDigits(currency);
    return NumberFormat.currency(
      symbol: '',
      decimalDigits:
          decimalDigits ?? (amount % 1 == 0 ? 0 : currencyDecimalDigits),
    ).format(amount);
  }
}
