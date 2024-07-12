import 'package:decimal/decimal.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:tbdex/tbdex.dart';

class PaymentAmountState {
  String? payinAmount;
  String? payoutAmount;
  String? filterCurrency;
  String? pfiDid;
  Offering? selectedOffering;
  Map<Pfi, List<Offering>>? offeringsMap;

  PaymentAmountState({
    this.payinAmount,
    this.payoutAmount,
    this.filterCurrency,
    this.pfiDid,
    this.selectedOffering,
    this.offeringsMap,
  });

  Decimal get payinDecimalAmount => Decimal.parse(payinAmount ?? '0');
  Decimal get payoutDecimalAmount => Decimal.parse(payoutAmount ?? '0');

  String? get payinCurrency => selectedOffering?.data.payin.currencyCode;
  String? get payoutCurrency => selectedOffering?.data.payout.currencyCode;

  String? get exchangeRate => selectedOffering?.data.payoutUnitsPerPayinUnit;
  String? get offeringId => selectedOffering?.metadata.id;

  PaymentAmountState copyWith({
    String? payinAmount,
    String? payoutAmount,
    String? filterCurrency,
    String? pfiDid,
    Offering? selectedOffering,
    Map<Pfi, List<Offering>>? offeringsMap,
  }) {
    return PaymentAmountState(
      payinAmount: payinAmount ?? this.payinAmount,
      payoutAmount: payoutAmount ?? this.payoutAmount,
      filterCurrency: filterCurrency ?? this.filterCurrency,
      pfiDid: pfiDid ?? this.pfiDid,
      selectedOffering: selectedOffering ?? this.selectedOffering,
      offeringsMap: offeringsMap ?? this.offeringsMap,
    );
  }
}
