import 'package:dap/dap.dart';
import 'package:didpay/features/payment/payment_method.dart';

class DapState {
  final MoneyAddress? selectedAddress;
  final List<MoneyAddress>? moneyAddresses;

  DapState({
    this.selectedAddress,
    this.moneyAddresses,
  });

  static const Map<String, String> protocolToKindMap = {
    'addr': 'BTC_ONCHAIN_PAYOUT',
    'lnaddr': 'BTC_LN_PAYOUT',
    'sol': 'USDC_ONCHAIN',
    'eth': 'USDC_ONCHAIN',
  };

  String? get protocol => selectedAddress?.protocol;

  String? get paymentAddress => selectedAddress?.pss;

  List<String>? get currencies =>
      moneyAddresses?.map((address) => address.currency).toList();

  MoneyAddress? getSelectedMoneyAddress(String? paymentCurrency) =>
      moneyAddresses?.firstWhere(
        (address) => address.currency.toUpperCase() == paymentCurrency,
      );

  List<PaymentMethod>? filterPaymentMethods(
    List<PaymentMethod>? paymentMethods,
  ) {
    final protocolKinds = moneyAddresses
        ?.map(
          (address) =>
              protocolToKindMap[address.pss.split(':').firstOrNull ?? ''],
        )
        .toSet();

    final filteredMethods = paymentMethods
        ?.where(
          (method) => protocolKinds?.contains(method.kind) ?? false,
        )
        .toList();

    return filteredMethods?.isEmpty ?? true ? null : filteredMethods;
  }

  DapState copyWith({
    MoneyAddress? selectedAddress,
    List<MoneyAddress>? moneyAddresses,
  }) =>
      DapState(
        selectedAddress: selectedAddress ?? this.selectedAddress,
        moneyAddresses: moneyAddresses ?? this.moneyAddresses,
      );
}
