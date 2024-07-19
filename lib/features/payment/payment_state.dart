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
        return paymentDetailsState?.moneyAddresses?.firstOrNull?.currency
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
        // TODO(ethan-tbd): remove hardcoded map
        return {
          'lnAddress': paymentDetailsState?.moneyAddresses?.firstOrNull?.css
                  .split(':')
                  .last ??
              '',
        };
      case TransactionType.withdraw:
        return paymentDetailsState?.formData;
    }
  }

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
