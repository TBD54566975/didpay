import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:tbdex/tbdex.dart';

class Transaction {
  final double payinAmount;
  final double payoutAmount;
  final String payinCurrency;
  final String payoutCurrency;
  final DateTime createdAt;
  final TransactionStatus status;
  final TransactionType type;

  Transaction({
    required this.payinAmount,
    required this.payoutAmount,
    required this.payinCurrency,
    required this.payoutCurrency,
    required this.createdAt,
    required this.status,
    required this.type,
  });

  factory Transaction.fromExchange(Exchange exchange) {
    var payinAmount = '0';
    var payoutAmount = '0';
    var payinCurrency = '';
    var payoutCurrency = '';
    var latestCreatedAt = DateTime.fromMillisecondsSinceEpoch(0);
    var status = TransactionStatus.pending;
    var type = TransactionType.send;

    for (final msg in exchange) {
      switch (msg.metadata.kind) {
        case MessageKind.rfq:
          payinAmount = (msg as Rfq).data.payin.amount;
          break;
        case MessageKind.quote:
          payinAmount = (msg as Quote).data.payin.amount;
          payoutAmount = msg.data.payout.amount;
          payinCurrency = msg.data.payin.currencyCode;
          payoutCurrency = msg.data.payout.currencyCode;
          break;
        case MessageKind.order:
          status = TransactionStatus.completed;
          break;
        // TODO(ethan-tbd): add additional order statuses
        case MessageKind.orderstatus:
          status = TransactionStatus.completed;
          break;
        case MessageKind.close:
          status = TransactionStatus.failed;
          break;
      }
    }

    type = (payinCurrency == 'STORED_BALANCE')
        ? TransactionType.withdraw
        : (payoutCurrency == 'STORED_BALANCE')
            ? TransactionType.deposit
            : type;

    return Transaction(
      payinAmount: double.parse(payinAmount),
      payoutAmount: double.parse(payoutAmount),
      payinCurrency: payinCurrency,
      payoutCurrency: payoutCurrency,
      createdAt: latestCreatedAt,
      status: status,
      type: type,
    );
  }

  static Icon getIcon(TransactionType type, {double size = Grid.sm}) {
    switch (type) {
      case TransactionType.deposit:
        return Icon(Icons.south_west, size: size);
      case TransactionType.withdraw:
        return Icon(Icons.north_east, size: size);
      case TransactionType.send:
        return Icon(Icons.attach_money, size: size);
    }
  }
}

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
