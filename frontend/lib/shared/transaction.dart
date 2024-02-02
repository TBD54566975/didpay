import 'package:hooks_riverpod/hooks_riverpod.dart';

// TODO: remove this file when FTL generated types are available
class Transaction {
  final String type;
  final String status;
  final double amount;

  Transaction({
    required this.type,
    required this.status,
    required this.amount,
  });
}

final _defaultList = [
  Transaction(type: 'Deposit', status: 'Quoted', amount: 4.61),
  Transaction(type: 'Withdrawal', status: 'Quoted', amount: 20.85),
  Transaction(type: 'Deposit', status: 'Completed', amount: 10.99),
  Transaction(type: 'Withdrawal', status: 'Completed', amount: 7.03),
  Transaction(type: 'Withdrawal', status: 'Failed', amount: 5.42),
];

final transactionsProvider = StateProvider<List<Transaction>>((ref) {
  return _defaultList;
});
