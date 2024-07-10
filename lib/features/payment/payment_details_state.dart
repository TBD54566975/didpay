import 'package:tbdex/tbdex.dart';

class PaymentDetailsState {
  final List<PaymentMethod>? paymentMethods;
  final PaymentMethod? selectedPaymentMethod;

  PaymentDetailsState({
    required this.paymentMethods,
    this.selectedPaymentMethod,
  });

  Set<String>? get paymentTypes =>
      paymentMethods?.map((method) => method.type).whereType<String>().toSet();

  bool get hasNoPaymentTypes => paymentTypes?.isEmpty ?? true;
  bool get hasMultiplePaymentTypes => (paymentTypes?.length ?? 0) > 1;

  List<PaymentMethod>? filterPaymentMethods(
    String? paymentType,
  ) =>
      paymentMethods
          ?.where(
            (method) => method.type?.contains(paymentType ?? '') ?? true,
          )
          .toList();
}

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
}
