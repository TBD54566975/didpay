import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class Currency {
  final double exchangeRate;
  final String label;
  final IconData icon;

  Currency({
    required this.exchangeRate,
    required this.label,
    required this.icon,
  });

  static String formatFromString(String amount, {String? currency}) {
    final parsedAmount = double.tryParse(amount) ?? 0.0;

    if (currency == 'BTC') {
      return NumberFormat.currency(
        symbol: '₿',
        decimalDigits: amount.contains('.') ? 8 : 0,
      ).format(parsedAmount);
    }

    return NumberFormat.simpleCurrency(
      name: currency,
      decimalDigits: amount.contains('.') ? 2 : 0,
    ).format(parsedAmount);
  }

  static String formatFromDouble(double amount, {String? currency}) {
    if (currency == 'BTC') {
      return NumberFormat.currency(
        symbol: '₿',
        decimalDigits: amount % 1 == 0 ? 0 : 8,
      ).format(amount);
    }

    return NumberFormat.simpleCurrency(
      name: currency,
      decimalDigits: amount % 1 == 0 ? 0 : 2,
    ).format(amount);
  }
}

final _defaultList = [
  Currency(exchangeRate: 1, label: 'USD', icon: Icons.attach_money),
  Currency(exchangeRate: 17, label: 'MXN', icon: Icons.attach_money),
  Currency(exchangeRate: 0.000024, label: 'BTC', icon: Icons.currency_bitcoin),
];

final currencyProvider = Provider<List<Currency>>((ref) {
  return _defaultList;
});
