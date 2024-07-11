import 'package:didpay/features/payment/payment_amount_state.dart';
import 'package:didpay/features/payment/payment_details_state.dart';
import 'package:didpay/features/transaction/transaction.dart';

class PaymentState {
  final TransactionType transactionType;
  final PaymentAmountState? paymentAmountState;
  final PaymentDetailsState? paymentDetailsState;

  const PaymentState({
    required this.transactionType,
    this.paymentAmountState,
    this.paymentDetailsState,
  });

  PaymentState copyWith({
    PaymentAmountState? paymentAmountState,
    PaymentDetailsState? paymentDetailsState,
  }) {
    return PaymentState(
      transactionType: transactionType,
      paymentAmountState: paymentAmountState ?? this.paymentAmountState,
      paymentDetailsState: paymentDetailsState ?? this.paymentDetailsState,
    );
  }
}
