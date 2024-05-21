import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:tbdex/tbdex.dart';

class Transaction {
  final double payinAmount;
  final double payoutAmount;
  final String payinCurrency;
  final String payoutCurrency;
  final DateTime createdAt;
  final TransactionType type;
  final TransactionStatus status;

  Transaction({
    required this.payinAmount,
    required this.payoutAmount,
    required this.payinCurrency,
    required this.payoutCurrency,
    required this.createdAt,
    required this.type,
    required this.status,
  });

  factory Transaction.fromExchange(Exchange exchange) {
    var payinAmount = '0';
    var payoutAmount = '0';
    var payinCurrency = '';
    var payoutCurrency = '';
    var status = TransactionStatus.paymentReceived;
    var latestCreatedAt = DateTime.fromMillisecondsSinceEpoch(0);
    var type = TransactionType.send;

    for (final msg in exchange) {
      final createdAt = DateTime.parse(msg.metadata.createdAt);

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
          break;
        case MessageKind.orderstatus:
          if (createdAt.isAfter(latestCreatedAt)) {
            status = _getStatus((msg as OrderStatus).data.orderStatus);
          }
          break;
        case MessageKind.close:
          status = TransactionStatus.paymentCanceled;
          break;
      }

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

  static Icon getIcon(TransactionType type, {double size = Grid.xs}) {
    switch (type) {
      case TransactionType.deposit:
        return Icon(Icons.south_west, size: size);
      case TransactionType.withdraw:
        return Icon(Icons.north_east, size: size);
      case TransactionType.send:
        return Icon(Icons.send, size: size);
    }
  }

  static TransactionStatus _getStatus(String status) {
    switch (status) {
      case 'PAYOUT_PENDING':
        return TransactionStatus.paymentPending;
      case 'PAYOUT_INITIATED':
        return TransactionStatus.paymentInitiated;
      case 'PAYOUT_COMPLETED':
        return TransactionStatus.paymentComplete;
      default:
        return TransactionStatus.paymentReceived;
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

enum TransactionStatus {
  paymentReceived,
  paymentPending,
  paymentInitiated,
  paymentComplete,
  paymentCanceled;

  @override
  String toString() => name
      .replaceAllMapped(RegExp('([A-Z])'), (match) => ' ${match.group(0)}')
      .trim()
      .toLowerCase()
      .replaceFirst(name[0], name[0].toUpperCase());
}
