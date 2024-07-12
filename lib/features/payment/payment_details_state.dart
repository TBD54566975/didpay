import 'package:dap/dap.dart';
import 'package:didpay/features/payment/payment_method.dart';

class PaymentDetailsState {
  final String? paymentCurrency;
  final String? paymentName;
  final String? selectedPaymentType;
  final PaymentMethod? selectedPaymentMethod;
  final List<PaymentMethod>? paymentMethods;
  final List<MoneyAddress>? moneyAddresses;
  final List<String>? credentialsJwt;
  final Map<String, String>? formData;

  PaymentDetailsState({
    this.paymentCurrency,
    this.paymentName,
    this.selectedPaymentType,
    this.selectedPaymentMethod,
    this.paymentMethods,
    this.moneyAddresses,
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
    String? selectedPaymentType,
    PaymentMethod? selectedPaymentMethod,
    List<PaymentMethod>? paymentMethods,
    List<MoneyAddress>? moneyAddresses,
    List<String>? credentialsJwt,
    Map<String, String>? formData,
  }) {
    return PaymentDetailsState(
      paymentCurrency: paymentCurrency ?? this.paymentCurrency,
      paymentName: paymentName ?? this.paymentName,
      selectedPaymentType: selectedPaymentType ?? this.selectedPaymentType,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      moneyAddresses: moneyAddresses ?? this.moneyAddresses,
      credentialsJwt: credentialsJwt ?? this.credentialsJwt,
      formData: formData ?? this.formData,
    );
  }
}
