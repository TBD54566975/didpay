import 'package:tbdex/tbdex.dart';

class PaymentMethod {
  final String kind;
  final String? name;
  final String? type;
  final String? schema;
  final String? fee;

  PaymentMethod({
    required this.kind,
    this.name,
    this.type,
    this.schema,
    this.fee,
  });

  factory PaymentMethod.fromPayinMethod(PayinMethod method) => PaymentMethod(
        kind: method.kind,
        name: method.name,
        type: method.group,
        schema: method.requiredPaymentDetails?.toJson(),
        fee: method.fee,
      );

  factory PaymentMethod.fromPayoutMethod(PayoutMethod method) => PaymentMethod(
        kind: method.kind,
        name: method.name,
        type: method.group,
        schema: method.requiredPaymentDetails?.toJson(),
        fee: method.fee,
      );

  String get title => name ?? kind;

  PaymentMethod copyWith({
    String? kind,
    String? name,
    String? type,
    String? schema,
    String? fee,
  }) {
    return PaymentMethod(
      kind: kind ?? this.kind,
      name: name ?? this.name,
      type: type ?? this.type,
      schema: schema ?? this.schema,
      fee: fee ?? this.fee,
    );
  }

  static const Map<String, String> protocolPaymentMap = {
    'addr': 'BTC_ONCHAIN_PAYOUT',
    'lnaddr': 'BTC_LN_PAYOUT',
  };
}
