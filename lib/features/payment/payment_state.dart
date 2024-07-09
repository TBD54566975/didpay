import 'package:dap/dap.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:tbdex/tbdex.dart';
import 'package:web5/web5.dart';

class PaymentState {
  final TransactionType transactionType;
  final Rfq? _rfq;
  final Offering? _offering;
  final GetOfferingsFilter? _getOfferingsFilter;
  final Pfi? _pfi;
  final Dap? _dap;
  final String? _paymentName;
  final List<MoneyAddress>? _moneyAddresses;
  final Map<String, String>? _paymentDetails;
  final Map<Pfi, List<Offering>>? _offeringsMap;

  const PaymentState({
    required this.transactionType,
    Rfq? rfq,
    Offering? offering,
    GetOfferingsFilter? getOfferingsFilter,
    Pfi? pfi,
    Dap? dap,
    String? paymentName,
    List<MoneyAddress>? moneyAddresses,
    Map<String, String>? paymentDetails,
    Map<Pfi, List<Offering>>? offeringsMap,
  })  : _rfq = rfq,
        _offering = offering,
        _getOfferingsFilter = getOfferingsFilter,
        _pfi = pfi,
        _dap = dap,
        _paymentName = paymentName,
        _moneyAddresses = moneyAddresses,
        _paymentDetails = paymentDetails,
        _offeringsMap = offeringsMap;

  PaymentState setPaymentAmountData(
    BearerDid did,
    String payinAmount,
    String payoutAmount,
    Pfi? selectedPfi,
    Offering? selectedOffering,
    Map<Pfi, List<Offering>> offeringsMap,
  ) {
    final rfqData = CreateRfqData(
      offeringId: selectedOffering?.metadata.id ?? '',
      payin: CreateSelectedPayinMethod(
        amount: payinAmount,
        kind: '',
      ),
      payout: CreateSelectedPayoutMethod(
        kind: '',
      ),
    );

    return copyWith(
      rfq: Rfq.create(selectedPfi?.did ?? '', did.uri, rfqData),
      offering: selectedOffering,
      offeringsMap: offeringsMap,
      pfi: selectedPfi,
    );
  }

  PaymentState setPaymentDetailsData({
    PayinMethod? payinMethod,
    PayoutMethod? payoutMethod,
    String? paymentName,
    Map<String, String>? paymentDetails,
    List<String>? claims,
  }) {
    final rfqData = CreateRfqData(
      offeringId: _rfq?.data.offeringId ?? '',
      payin: CreateSelectedPayinMethod(
        amount: _rfq?.data.payin.amount ?? '',
        kind: payinMethod?.kind ?? payinMethods?.firstOrNull?.kind ?? '',
        paymentDetails: payinMethod == null ? null : paymentDetails,
      ),
      payout: CreateSelectedPayoutMethod(
        kind: payoutMethod?.kind ?? payoutMethods?.firstOrNull?.kind ?? '',
        paymentDetails: payoutMethod == null ? null : paymentDetails,
      ),
      claims: claims,
    );

    return copyWith(
      rfq: Rfq.create(
        _rfq?.metadata.to ?? '',
        _rfq?.metadata.from ?? '',
        rfqData,
      ),
      paymentName: paymentName,
      paymentDetails: paymentDetails,
    );
  }

  PaymentState copyWith({
    TransactionType? transactionType,
    Rfq? rfq,
    Offering? offering,
    GetOfferingsFilter? getOfferingsFilter,
    Pfi? pfi,
    Dap? dap,
    String? paymentName,
    List<MoneyAddress>? moneyAddresses,
    Map<String, String>? paymentDetails,
    Map<Pfi, List<Offering>>? offeringsMap,
  }) {
    return PaymentState(
      transactionType: transactionType ?? this.transactionType,
      rfq: rfq ?? _rfq,
      offering: offering ?? _offering,
      getOfferingsFilter: getOfferingsFilter ?? _getOfferingsFilter,
      pfi: pfi ?? _pfi,
      dap: dap ?? _dap,
      paymentName: paymentName ?? _paymentName,
      moneyAddresses: moneyAddresses ?? _moneyAddresses,
      paymentDetails: paymentDetails ?? _paymentDetails,
      offeringsMap: offeringsMap ?? _offeringsMap,
    );
  }

  Rfq? get rfq => _rfq;

  Offering? get offering => _offering;

  GetOfferingsFilter? get offeringsFilter => _getOfferingsFilter;

  Pfi? get pfi => _pfi;

  Dap? get dap => _dap;

  String? get payinAmount => _rfq?.data.payin.amount;

  String? get payinCurrency => _offering?.data.payin.currencyCode;

  String? get payoutCurrency => _offering?.data.payin.currencyCode;

  String? get pfiDid => _rfq?.metadata.to;

  String? get exchangeId => _rfq?.metadata.id;

  String? get paymentName => _dap != null ? _dap?.dap : _paymentName;

  List<PayinMethod>? get payinMethods => _offering?.data.payin.methods;

  List<PayoutMethod>? get payoutMethods => _offering?.data.payout.methods;

  List<MoneyAddress>? get moneyAddresses => _moneyAddresses;

  Map<String, String>? get paymentDetails => _paymentDetails;

  Map<Pfi, List<Offering>>? get offeringsMap => _offeringsMap;
}
