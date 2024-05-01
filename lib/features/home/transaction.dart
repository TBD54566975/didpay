import 'package:hooks_riverpod/hooks_riverpod.dart';

// TODO(ethan-tbd): remove this file, https://github.com/TBD54566975/didpay/issues/136
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
    payinCurrency: 'MXN',
    payoutCurrency: 'USDC',
    status: TransactionStatus.pending,
    type: TransactionType.deposit,
  ),
  Transaction(
    payinAmount: 1,
    payoutAmount: 17,
    payinCurrency: 'USDC',
    payoutCurrency: 'MXN',
    status: TransactionStatus.pending,
    type: TransactionType.withdraw,
  ),
  Transaction(
    payinAmount: 0.00085,
    payoutAmount: 35.42,
    payinCurrency: 'BTC',
    payoutCurrency: 'USDC',
    status: TransactionStatus.completed,
    type: TransactionType.deposit,
  ),
  Transaction(
    payinAmount: 33,
    payoutAmount: 0.000792,
    payinCurrency: 'USDC',
    payoutCurrency: 'BTC',
    status: TransactionStatus.completed,
    type: TransactionType.withdraw,
  ),
  Transaction(
    payinAmount: 1,
    payoutAmount: 1,
    payinCurrency: 'USDC',
    payoutCurrency: 'USD',
    status: TransactionStatus.failed,
    type: TransactionType.withdraw,
  ),
];

final transactionsProvider = StateProvider<List<Transaction>>((ref) {
  return _defaultList;
});

enum TransactionStatus {
  failed,
  pending,
  completed;

  @override
  String toString() => name.substring(0, 1).toUpperCase() + name.substring(1);
}

enum TransactionType {
  deposit,
  withdraw,
  send;

  @override
  String toString() => name.substring(0, 1).toUpperCase() + name.substring(1);
}
