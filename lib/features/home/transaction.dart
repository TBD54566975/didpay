import 'package:didpay/features/currency/currency.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// TODO: remove this file when FTL generated types are available
class Transaction {
  final double payinAmount;
  final double payoutAmount;
  final String payinCurrency;
  final String payoutCurrency;
  final TransactionStatus status;
  final TransactionType type;

  Transaction({
    required this.payinAmount,
    required this.payoutAmount,
    required this.payinCurrency,
    required this.payoutCurrency,
    required this.status,
    required this.type,
  });
}

final _defaultList = [
  Transaction(
    payinAmount: 25,
    payoutAmount: 1.47,
    payinCurrency: CurrencyCode.mxn.toString(),
    payoutCurrency: CurrencyCode.usdc.toString(),
    status: TransactionStatus.quoted,
    type: TransactionType.deposit,
  ),
  Transaction(
    payinAmount: 1,
    payoutAmount: 17,
    payinCurrency: CurrencyCode.usdc.toString(),
    payoutCurrency: CurrencyCode.mxn.toString(),
    status: TransactionStatus.quoted,
    type: TransactionType.withdraw,
  ),
  Transaction(
    payinAmount: 0.00085,
    payoutAmount: 35.42,
    payinCurrency: CurrencyCode.btc.toString(),
    payoutCurrency: CurrencyCode.usdc.toString(),
    status: TransactionStatus.completed,
    type: TransactionType.deposit,
  ),
  Transaction(
    payinAmount: 33,
    payoutAmount: 0.000792,
    payinCurrency: CurrencyCode.usdc.toString(),
    payoutCurrency: CurrencyCode.btc.toString(),
    status: TransactionStatus.completed,
    type: TransactionType.withdraw,
  ),
  Transaction(
    payinAmount: 1,
    payoutAmount: 1,
    payinCurrency: CurrencyCode.usdc.toString(),
    payoutCurrency: CurrencyCode.usd.toString(),
    status: TransactionStatus.failed,
    type: TransactionType.withdraw,
  ),
];

final transactionsProvider = StateProvider<List<Transaction>>((ref) {
  return _defaultList;
});

enum TransactionStatus {
  failed,
  quoted,
  completed;

  @override
  String toString() => name.substring(0, 1).toUpperCase() + name.substring(1);
}

enum TransactionType {
  deposit,
  withdraw;

  @override
  String toString() => name.substring(0, 1).toUpperCase() + name.substring(1);
}
