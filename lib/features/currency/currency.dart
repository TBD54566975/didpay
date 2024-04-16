import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Currency {
  final double exchangeRate;
  final CurrencyCode code;
  final IconData icon;

  Currency({
    required this.exchangeRate,
    required this.code,
    required this.icon,
  });
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
