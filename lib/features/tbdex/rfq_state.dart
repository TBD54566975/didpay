import 'package:tbdex/tbdex.dart';

class RfqState {
  final String? payinAmount;
  final Offering? offering;
  final PayinMethod? payinMethod;
  final PayoutMethod? payoutMethod;

  const RfqState({
    this.payinAmount,
    this.offering,
    this.payinMethod,
    this.payoutMethod,
  });

  RfqState copyWith({
    String? payinAmount,
    Offering? offering,
    PayinMethod? payinMethod,
    PayoutMethod? payoutMethod,
  }) {
    return RfqState(
      payinAmount: payinAmount ?? this.payinAmount,
      offering: offering ?? this.offering,
      payinMethod: payinMethod ?? this.payinMethod,
      payoutMethod: payoutMethod ?? this.payoutMethod,
    );
  }

  @override
  String toString() {
    return 'RfqState(payinAmount: $payinAmount, offering: ${offering?.toJson()}, payinMethod: $payinMethod, payoutMethod: $payoutMethod)';
  }
}
