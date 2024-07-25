import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:tbdex/tbdex.dart';

class Transaction {
  final String payinAmount;
  final String payoutAmount;
  final String payinCurrency;
  final String payoutCurrency;
  final DateTime createdAt;
  final TransactionType type;
  final TransactionStatus status;

  const Transaction({
    required this.payinAmount,
    required this.payoutAmount,
    required this.payinCurrency,
    required this.payoutCurrency,
    required this.createdAt,
    required this.type,
    required this.status,
  });

  factory Transaction.fromExchange(Exchange? exchange) {
    var payinAmount = '0';
    var payoutAmount = '0';
    var payinCurrency = '';
    var payoutCurrency = '';
    var status = TransactionStatus.orderSubmitted;
    var latestCreatedAt = DateTime.fromMillisecondsSinceEpoch(0);
    var type = TransactionType.send;

    if (exchange != null) {
      for (final msg in exchange) {
        final createdAt = DateTime.parse(msg.metadata.createdAt);

        switch (msg.metadata.kind) {
          case MessageKind.rfq:
            payinAmount = (msg as Rfq).data.payin.amount;
            break;
          case MessageKind.quote:
            payinAmount = (msg as Quote).data.payin.total;
            payoutAmount = msg.data.payout.total;
            payinCurrency = msg.data.payin.currencyCode;
            payoutCurrency = msg.data.payout.currencyCode;
            break;
          case MessageKind.order:
            break;
          case MessageKind.orderstatus:
            if (createdAt.isAfter(latestCreatedAt)) {
              status =
                  _statusToTransactionStatus((msg as OrderStatus).data.status);
            }
            break;
          case MessageKind.orderinstructions:
            break;
          case MessageKind.close:
            ((msg as Close).data.success ?? false)
                ? status = TransactionStatus.payoutSuccess
                : status = TransactionStatus.payoutCanceled;
            break;
          case MessageKind.cancel:
            status = TransactionStatus.payoutCanceled;
        }

        if (createdAt.isAfter(latestCreatedAt)) {
          latestCreatedAt = createdAt;
        }
      }
    }

    type = (payinCurrency == 'USDC')
        ? TransactionType.withdraw
        : (payoutCurrency == 'USDC')
            ? TransactionType.deposit
            : type;

    return Transaction(
      payinAmount: payinAmount,
      payoutAmount: payoutAmount,
      payinCurrency: payinCurrency,
      payoutCurrency: payoutCurrency,
      createdAt: latestCreatedAt,
      status: status,
      type: type,
    );
  }

  Map<String, dynamic> toJson() => {
        'payinAmount': payinAmount,
        'payoutAmount': payoutAmount,
        'payinCurrency': payinCurrency,
        'payoutCurrency': payoutCurrency,
        'createdAt': createdAt.toIso8601String(),
        'type': type.name,
        'status': status.name,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        payinAmount: json['payinAmount'],
        payoutAmount: json['payoutAmount'],
        payinCurrency: json['payinCurrency'],
        payoutCurrency: json['payoutCurrency'],
        createdAt: DateTime.parse(json['createdAt']),
        type: TransactionType.values.firstWhere((e) => e.name == json['type']),
        status: TransactionStatus.values.firstWhere(
          (e) => e.name == json['status'],
        ),
      );

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

  static bool isClosed(TransactionStatus? status) =>
      status == TransactionStatus.payoutSuccess ||
      status == TransactionStatus.payoutCanceled;

  static Color getStatusColor(
    BuildContext context,
    TransactionStatus? status,
  ) {
    switch (status) {
      case TransactionStatus.payoutSuccess:
        return Theme.of(context).colorScheme.tertiary;
      case TransactionStatus.payoutCanceled:
        return Theme.of(context).colorScheme.error;
      case TransactionStatus.payoutPending:
      case TransactionStatus.payoutInitiated:
      case TransactionStatus.payoutComplete:
      case TransactionStatus.orderSubmitted:
      case null:
        return Theme.of(context).colorScheme.outline;
    }
  }

  static TransactionStatus _statusToTransactionStatus(Status status) {
    switch (status) {
      case Status.payinPending:
      case Status.payinInitiated:
      case Status.payinSettled:
      case Status.payoutPending:
      case Status.payoutInitiated:
        return TransactionStatus.payoutPending;

      case Status.payoutSettled:
        return TransactionStatus.payoutComplete;

      case Status.payinFailed:
      case Status.payinExpired:
      case Status.payoutFailed:
      case Status.refundFailed:
        return TransactionStatus.payoutCanceled;

      case Status.refundSettled:
      case Status.refundInitiated:
      case Status.refundPending:
        return TransactionStatus.payoutPending;
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
  orderSubmitted,
  payoutPending,
  payoutInitiated,
  payoutComplete,
  payoutSuccess,
  payoutCanceled;

  @override
  String toString() => name
      .replaceAllMapped(RegExp('([A-Z])'), (match) => ' ${match.group(0)}')
      .trim()
      .toLowerCase()
      .replaceFirst(name[0], name[0].toUpperCase());
}
