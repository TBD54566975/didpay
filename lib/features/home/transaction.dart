import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:tbdex/tbdex.dart';

class Transaction {
  final double payinAmount;
  final double payoutAmount;
  final String payinCurrency;
  final String payoutCurrency;
  final String status;
  final DateTime createdAt;
  final TransactionType type;

  Transaction({
    required this.payinAmount,
    required this.payoutAmount,
    required this.payinCurrency,
    required this.payoutCurrency,
    required this.status,
    required this.createdAt,
    required this.type,
  });

  factory Transaction.fromExchange(Exchange exchange) {
    var payinAmount = '0';
    var payoutAmount = '0';
    var payinCurrency = '';
    var payoutCurrency = '';
    var status = '';
    var latestCreatedAt = DateTime.fromMillisecondsSinceEpoch(0);
    var type = TransactionType.send;

    for (final msg in exchange) {
      switch (msg.metadata.kind) {
        case MessageKind.rfq:
          status = 'Request submitted';
          payinAmount = (msg as Rfq).data.payin.amount;
          break;
        case MessageKind.quote:
          status = 'Quote received';
          payinAmount = (msg as Quote).data.payin.amount;
          payoutAmount = msg.data.payout.amount;
          payinCurrency = msg.data.payin.currencyCode;
          payoutCurrency = msg.data.payout.currencyCode;
          break;
        case MessageKind.order:
          status = 'Order submitted';
          break;
        // TODO(ethan-tbd): add additional order statuses
        case MessageKind.orderstatus:
          status = (msg as OrderStatus).data.orderStatus;
          break;
        case MessageKind.close:
          status = 'Canceled';
          break;
      }

      final createdAt = DateTime.parse(msg.metadata.createdAt);
      if (createdAt.isAfter(latestCreatedAt)) {
        latestCreatedAt = createdAt;
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

enum TransactionType {
  deposit,
  withdraw,
  send;

  @override
  String toString() => name.substring(0, 1).toUpperCase() + name.substring(1);
}
