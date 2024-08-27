import 'package:didpay/features/payment/payment_method.dart';

class PaymentDetailsState {
  final String? paymentCurrency;
  final String? paymentName;
  final String? exchangeId;
  final String? selectedPaymentType;
  final PaymentMethod? selectedPaymentMethod;
  final List<PaymentMethod>? paymentMethods;
  final List<String>? credentialsJwt;
  final Map<String, String>? formData;

  PaymentDetailsState({
    this.paymentCurrency,
    this.paymentName,
    this.exchangeId,
    this.selectedPaymentType,
    this.selectedPaymentMethod,
    this.paymentMethods,
    this.credentialsJwt,
    this.formData,
  });

  Set<String>? get paymentTypes =>
      paymentMethods?.map((method) => method.type).whereType<String>().toSet();

  bool get hasNoPaymentTypes => paymentTypes?.isEmpty ?? true;
  bool get hasMultiplePaymentTypes => (paymentTypes?.length ?? 0) > 1;

  List<PaymentMethod>? filterPaymentMethods(String? paymentType) =>
      paymentMethods
          ?.where(
            (method) => method.type?.contains(paymentType ?? '') ?? true,
          )
          .toList();

  PaymentDetailsState copyWith({
    String? paymentCurrency,
    String? paymentName,
    String? exchangeId,
    String? selectedPaymentType,
    PaymentMethod? selectedPaymentMethod,
    List<PaymentMethod>? paymentMethods,
    List<String>? credentialsJwt,
    Map<String, String>? formData,
  }) {
    return PaymentDetailsState(
      paymentCurrency: paymentCurrency ?? this.paymentCurrency,
      paymentName: paymentName ?? this.paymentName,
      exchangeId: exchangeId ?? this.exchangeId,
      selectedPaymentType: selectedPaymentType ?? this.selectedPaymentType,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      credentialsJwt: credentialsJwt ?? this.credentialsJwt,
      formData: formData ?? this.formData,
    );
  }
}
