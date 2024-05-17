import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/tbdex/rfq_state.dart';
import 'package:didpay/shared/json_schema_form.dart';
import 'package:flutter/material.dart';
import 'package:tbdex/tbdex.dart';

class PaymentDetails {
  static Widget buildForm(
    BuildContext context,
    RfqState rfqState,
    PaymentState paymentState, {
    required void Function(PaymentState) onPaymentSubmit,
  }) {
    final paymentMethod =
        paymentState.transactionType == TransactionType.deposit
            ? rfqState.payinMethod
            : rfqState.payoutMethod;

    final isDisabled = paymentMethod.isDisabled;
    final schema = paymentMethod.schema;
    final fee = paymentMethod.serviceFee;
    final paymentName = paymentMethod.paymentName;

    return Expanded(
      child: JsonSchemaForm(
        schema: schema,
        isDisabled: isDisabled,
        onSubmit: (formData) {
          // TODO(mistermoe): check requiredClaims and navigate to kcc flow if needed, https://github.com/TBD54566975/didpay/issues/122
          onPaymentSubmit(
            paymentState.copyWith(
              serviceFee: fee,
              paymentName: paymentName,
              formData: formData,
            ),
          );
        },
      ),
    );
  }
}

extension _PaymentMethodOperations on Object? {
  bool get isDisabled => this == null;

  String? get schema => this is PayinMethod
      ? (this as PayinMethod?)?.requiredPaymentDetails?.toJson()
      : this is PayoutMethod
          ? (this as PayoutMethod?)?.requiredPaymentDetails?.toJson()
          : null;

  String? get serviceFee => this is PayinMethod
      ? (this as PayinMethod?)?.fee
      : this is PayoutMethod
          ? (this as PayoutMethod?)?.fee
          : null;

  String? get paymentName => this is PayinMethod
      ? (this as PayinMethod?)?.name ?? (this as PayinMethod?)?.kind
      : this is PayoutMethod
          ? (this as PayoutMethod?)?.name ?? (this as PayoutMethod?)?.kind
          : null;
}
