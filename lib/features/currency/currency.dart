import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class Currency {
  final double exchangeRate;
  final CurrencyCode code;
  final IconData icon;

  Currency({
    required this.exchangeRate,
    required this.code,
    required this.icon,
  });

  static int getDecimalDigits(CurrencyCode? currency) {
    switch (currency) {
      case CurrencyCode.btc:
        return 8;
      default:
        return 2;
    }
  }

  static String formatFromString(String amount, {String? currency}) {
    final decimalDigits =
        amount.contains('.') ? amount.split('.')[1].length : 0;
    final parsedAmount = double.tryParse(amount) ?? 0.0;
    return formatFromDouble(
      parsedAmount,
      currency: currency,
      decimalDigits: decimalDigits,
    );
  }

  static String formatFromDouble(double amount,
      {String? currency, int? decimalDigits}) {
    if (currency == CurrencyCode.btc.toString()) {
      return NumberFormat.currency(
        symbol: '',
        decimalDigits: decimalDigits ?? (amount % 1 == 0 ? 0 : 8),
      ).format(amount);
    }

    return NumberFormat.currency(
      symbol: '',
      decimalDigits: decimalDigits ?? (amount % 1 == 0 ? 0 : 2),
    ).format(amount);
  }
}

enum CurrencyCode {
  usdc,
  usd,
  mxn,
  btc;

  @override
  String toString() => name.toUpperCase();
}

final _defaultList = [
  Currency(
    exchangeRate: 1,
    code: CurrencyCode.usd,
    icon: Icons.attach_money,
  ),
  Currency(
    exchangeRate: 17,
    code: CurrencyCode.mxn,
    icon: Icons.attach_money,
  ),
  Currency(
    exchangeRate: 0.000024,
    code: CurrencyCode.btc,
    icon: Icons.currency_bitcoin,
  ),
];

final currencyProvider = Provider<List<Currency>>((ref) {
  return _defaultList;
});
