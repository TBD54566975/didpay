import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:tbdex/tbdex.dart';

class PaymentState {
  final TransactionType transactionType;
  final String? payinAmount;
  final String? payoutAmount;
  final String? payinCurrency;
  final String? payoutCurrency;
  final String? exchangeRate;
  final String? serviceFee;
  final String? paymentName;
  final String? exchangeId;
  final Pfi? selectedPfi;
  final Offering? selectedOffering;
  final PayinMethod? selectedPayinMethod;
  final PayoutMethod? selectedPayoutMethod;
  final List<PayinMethod>? payinMethods;
  final List<PayoutMethod>? payoutMethods;
  final Map<String, String>? formData;

  const PaymentState({
    required this.transactionType,
    this.payinAmount,
    this.payoutAmount,
    this.payinCurrency,
    this.payoutCurrency,
    this.exchangeRate,
    this.serviceFee,
    this.paymentName,
    this.exchangeId,
    this.selectedPfi,
    this.selectedOffering,
    this.selectedPayinMethod,
    this.selectedPayoutMethod,
    this.payinMethods,
    this.payoutMethods,
    this.formData,
  });

  PaymentState copyWith({
    TransactionType? transactionType,
    String? payinAmount,
    String? payoutAmount,
    String? payinCurrency,
    String? payoutCurrency,
    String? exchangeRate,
    String? serviceFee,
    String? paymentName,
    String? exchangeId,
    Pfi? selectedPfi,
    Offering? selectedOffering,
    PayinMethod? selectedPayinMethod,
    PayoutMethod? selectedPayoutMethod,
    List<PayinMethod>? payinMethods,
    List<PayoutMethod>? payoutMethods,
    Map<String, String>? formData,
  }) {
    return PaymentState(
      transactionType: transactionType ?? this.transactionType,
      payinAmount: payinAmount ?? this.payinAmount,
      payoutAmount: payoutAmount ?? this.payoutAmount,
      payinCurrency: payinCurrency ?? this.payinCurrency,
      payoutCurrency: payoutCurrency ?? this.payoutCurrency,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      serviceFee: serviceFee ?? this.serviceFee,
      paymentName: paymentName ?? this.paymentName,
      exchangeId: exchangeId ?? this.exchangeId,
      selectedPfi: selectedPfi ?? this.selectedPfi,
      selectedOffering: selectedOffering ?? this.selectedOffering,
      selectedPayinMethod: selectedPayinMethod ?? this.selectedPayinMethod,
      selectedPayoutMethod: selectedPayoutMethod ?? this.selectedPayoutMethod,
      payinMethods: payinMethods ?? this.payinMethods,
      payoutMethods: payoutMethods ?? this.payoutMethods,
      formData: formData ?? this.formData,
    );
  }
}
