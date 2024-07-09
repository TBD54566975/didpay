import 'package:tbdex/tbdex.dart';

abstract class PaymentMethods<T> {
  List<T>? get paymentMethods;
}

class PayinMethods extends PaymentMethods<PayinMethod> {
  final List<PayinMethod>? payinMethods;

  PayinMethods(this.payinMethods);

  @override
  List<PayinMethod>? get paymentMethods => payinMethods;
}

class PayoutMethods extends PaymentMethods<PayoutMethod> {
  final List<PayoutMethod>? payoutMethods;

  PayoutMethods(this.payoutMethods);

  @override
  List<PayoutMethod>? get paymentMethods => payoutMethods;
}
