import 'package:tbdex/tbdex.dart';

class RfqState {
  final String? payinAmount;
  final String? offeringId;
  final PayinMethod? payinMethod;
  final PayoutMethod? payoutMethod;

  const RfqState({
    this.payinAmount,
    this.offeringId,
    this.payinMethod,
    this.payoutMethod,
  });

  RfqState copyWith({
    String? payinAmount,
    String? offeringId,
    PayinMethod? payinMethod,
    PayoutMethod? payoutMethod,
  }) {
    return RfqState(
      payinAmount: payinAmount ?? this.payinAmount,
      offeringId: offeringId ?? this.offeringId,
      payinMethod: payinMethod ?? this.payinMethod,
      payoutMethod: payoutMethod ?? this.payoutMethod,
    );
  }

  @override
  String toString() {
    return 'RfqState(payinAmount: $payinAmount, offeringId: $offeringId, payinMethod: $payinMethod, payoutMethod: $payoutMethod)';
  }
}
