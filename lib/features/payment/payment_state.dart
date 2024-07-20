import 'package:didpay/features/payment/payment_amount_state.dart';
import 'package:didpay/features/payment/payment_details_state.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:tbdex/tbdex.dart';

class PaymentState {
  final TransactionType transactionType;
  final PaymentAmountState? paymentAmountState;
  final PaymentDetailsState? paymentDetailsState;
  final Quote? quote;

  const PaymentState({
    required this.transactionType,
    this.paymentAmountState,
    this.paymentDetailsState,
    this.quote,
  });

  String? get filterPayinCurrency {
    switch (transactionType) {
      case TransactionType.deposit:
      case TransactionType.send:
        return null;
      case TransactionType.withdraw:
        return 'USDC';
    }
  }

  String? get filterPayoutCurrency {
    switch (transactionType) {
      case TransactionType.deposit:
        return 'USDC';
      case TransactionType.send:
        return paymentDetailsState?.paymentCurrency ??
            paymentDetailsState?.moneyAddresses?.firstOrNull?.currency
                .toUpperCase();
      case TransactionType.withdraw:
        return null;
    }
  }

  Map<String, String>? get paymentDetails {
    switch (transactionType) {
      case TransactionType.deposit:
      case TransactionType.withdraw:
        return payinDetails;
      case TransactionType.send:
        return payoutDetails;
    }
  }

  String? get selectedPayinKind {
    switch (transactionType) {
      case TransactionType.deposit:
        return paymentDetailsState?.selectedPaymentMethod?.kind;
      case TransactionType.send:
      case TransactionType.withdraw:
        return paymentAmountState
            ?.selectedOffering?.data.payin.methods.firstOrNull?.kind;
    }
  }

  String? get selectedPayoutKind {
    switch (transactionType) {
      case TransactionType.deposit:
        return paymentAmountState
            ?.selectedOffering?.data.payout.methods.firstOrNull?.kind;
      case TransactionType.send:
      case TransactionType.withdraw:
        return paymentDetailsState?.selectedPaymentMethod?.kind;
    }
  }

  Map<String, String>? get payinDetails {
    switch (transactionType) {
      case TransactionType.deposit:
        return paymentDetailsState?.formData;
      case TransactionType.send:
      case TransactionType.withdraw:
        return null;
    }
  }

  Map<String, String>? get payoutDetails {
    switch (transactionType) {
      case TransactionType.deposit:
        return null;
      case TransactionType.send:
      case TransactionType.withdraw:
        return paymentDetailsState?.formData;
    }
  }

  PaymentState copyWith({
    PaymentAmountState? paymentAmountState,
    PaymentDetailsState? paymentDetailsState,
    Quote? quote,
  }) {
    return PaymentState(
      transactionType: transactionType,
      paymentAmountState: paymentAmountState ?? this.paymentAmountState,
      paymentDetailsState: paymentDetailsState ?? this.paymentDetailsState,
      quote: quote ?? this.quote,
    );
  }
}
