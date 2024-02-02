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
  Transaction(type: Type.deposit, status: Status.quoted, amount: 4.61),
  Transaction(type: Type.withdrawal, status: Status.quoted, amount: 20.85),
  Transaction(type: Type.deposit, status: Status.completed, amount: 10.99),
  Transaction(type: Type.withdrawal, status: Status.completed, amount: 7.03),
  Transaction(type: Type.withdrawal, status: Status.failed, amount: 5.42),
];

final transactionsProvider = StateProvider<List<Transaction>>((ref) {
  return _defaultList;
});

class Status {
  static const String failed = 'Failed';
  static const String quoted = 'Quoted';
  static const String completed = 'Completed';
}

class Type {
  static const String deposit = 'Deposit';
  static const String withdrawal = 'Withdrawal';
}
