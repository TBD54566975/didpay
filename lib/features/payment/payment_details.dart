import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/payment/review_payment_page.dart';
import 'package:didpay/features/tbdex/rfq_state.dart';
import 'package:didpay/features/tbdex/tbdex.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/json_schema_form.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

class PaymentDetails {
  static Widget buildForm(
    BuildContext context,
    WidgetRef ref,
    RfqState rfqState,
    PaymentState paymentState, {
    PayinMethod? payinMethod,
    PayoutMethod? payoutMethod,
  }) {
    bool isDisabled;
    String? schema;
    String? fee;
    String? paymentName;
    if (paymentState.transactionType == TransactionType.deposit) {
      isDisabled = payinMethod == null;
      schema = payinMethod?.requiredPaymentDetails?.toJson();
      fee = payinMethod?.fee;
      paymentName = payinMethod?.name ?? payinMethod?.kind;
    } else {
      isDisabled = payoutMethod == null;
      schema = payoutMethod?.requiredPaymentDetails?.toJson();
      fee = payoutMethod?.fee;
      paymentName = payoutMethod?.name ?? payoutMethod?.kind;
    }

    return isDisabled
        ? _buildDisabledButton(context)
        : Expanded(
            child: JsonSchemaForm(
              schema: schema,
              onSubmit: (formData) =>
                  // TODO(mistermoe): check requiredClaims and navigate to kcc flow if needed, https://github.com/TBD54566975/didpay/issues/122
                  Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ReviewPaymentPage(
                    rfq: Tbdex.createRfq(ref, rfqState),
                    paymentState: paymentState.copyWith(
                      serviceFee: fee,
                      paymentName: paymentName,
                      formData: formData,
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  static Widget _buildDisabledButton(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: Container()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Grid.side),
              child: FilledButton(
                onPressed: null,
                child: Text(Loc.of(context).next),
              ),
            ),
          ],
        ),
      );
}
