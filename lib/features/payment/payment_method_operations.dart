import 'package:tbdex/tbdex.dart';

extension PaymentMethodOperations on Object? {
  bool get isDisabled => this == null;

  String? get paymentSchema => this is PayinMethod
      ? (this as PayinMethod?)?.requiredPaymentDetails?.toJson()
      : this is PayoutMethod
          ? (this as PayoutMethod?)?.requiredPaymentDetails?.toJson()
          : null;

  String? get paymentFee => this is PayinMethod
      ? (this as PayinMethod?)?.fee
      : this is PayoutMethod
          ? (this as PayoutMethod?)?.fee
          : null;

  String? get paymentName => this is PayinMethod
      ? (this as PayinMethod?)?.name ?? (this as PayinMethod?)?.kind
      : this is PayoutMethod
          ? (this as PayoutMethod?)?.name ?? (this as PayoutMethod?)?.kind
          : null;

  String? get paymentGroup => this is PayinMethod
      ? (this as PayinMethod?)?.group
      : this is PayoutMethod
          ? (this as PayoutMethod?)?.group
          : null;
}
