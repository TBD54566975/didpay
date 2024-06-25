import 'package:dap/dap.dart';
import 'package:decimal/decimal.dart';
import 'package:didpay/features/countries/countries.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:tbdex/tbdex.dart';

class PaymentState {
  final TransactionType transactionType;
  final String? payinCurrency;
  final String? payoutCurrency;
  final String? serviceFee;
  final String? paymentName;
  final String? exchangeId;
  final Decimal? payinAmount;
  final Decimal? payoutAmount;
  final Decimal? exchangeRate;
  final List<MoneyAddress>? moneyAddresses;
  final Country? selectedCountry;
  final Pfi? selectedPfi;
  final Offering? selectedOffering;
  final PayinMethod? selectedPayinMethod;
  final PayoutMethod? selectedPayoutMethod;
  final List<PayinMethod>? payinMethods;
  final List<PayoutMethod>? payoutMethods;
  final List<String>? claims;
  final Map<String, String>? formData;
  final Map<Pfi, List<Offering>>? offeringsMap;

  const PaymentState({
    required this.transactionType,
    this.payinCurrency,
    this.payoutCurrency,
    this.serviceFee,
    this.paymentName,
    this.exchangeId,
    this.payinAmount,
    this.payoutAmount,
    this.exchangeRate,
    this.moneyAddresses,
    this.selectedCountry,
    this.selectedPfi,
    this.selectedOffering,
    this.selectedPayinMethod,
    this.selectedPayoutMethod,
    this.payinMethods,
    this.payoutMethods,
    this.claims,
    this.formData,
    this.offeringsMap,
  });

  PaymentState copyWith({
    TransactionType? transactionType,
    String? payinCurrency,
    String? payoutCurrency,
    String? serviceFee,
    String? paymentName,
    String? exchangeId,
    Decimal? payinAmount,
    Decimal? payoutAmount,
    Decimal? exchangeRate,
    List<MoneyAddress>? moneyAddresses,
    Country? selectedCountry,
    Pfi? selectedPfi,
    Offering? selectedOffering,
    PayinMethod? selectedPayinMethod,
    PayoutMethod? selectedPayoutMethod,
    List<PayinMethod>? payinMethods,
    List<PayoutMethod>? payoutMethods,
    List<String>? claims,
    Map<String, String>? formData,
    Map<Pfi, List<Offering>>? offeringsMap,
  }) {
    return PaymentState(
      transactionType: transactionType ?? this.transactionType,
      payinCurrency: payinCurrency ?? this.payinCurrency,
      payoutCurrency: payoutCurrency ?? this.payoutCurrency,
      serviceFee: serviceFee ?? this.serviceFee,
      paymentName: paymentName ?? this.paymentName,
      exchangeId: exchangeId ?? this.exchangeId,
      payinAmount: payinAmount ?? this.payinAmount,
      payoutAmount: payoutAmount ?? this.payoutAmount,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      moneyAddresses: moneyAddresses ?? this.moneyAddresses,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedPfi: selectedPfi ?? this.selectedPfi,
      selectedOffering: selectedOffering ?? this.selectedOffering,
      selectedPayinMethod: selectedPayinMethod ?? this.selectedPayinMethod,
      selectedPayoutMethod: selectedPayoutMethod ?? this.selectedPayoutMethod,
      payinMethods: payinMethods ?? this.payinMethods,
      payoutMethods: payoutMethods ?? this.payoutMethods,
      claims: claims ?? this.claims,
      formData: formData ?? this.formData,
      offeringsMap: offeringsMap ?? this.offeringsMap,
    );
  }
}
