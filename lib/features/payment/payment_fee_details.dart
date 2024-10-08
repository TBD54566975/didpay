import 'package:decimal/decimal.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/currency_formatter.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tbdex/tbdex.dart';

class PaymentFeeDetails extends HookWidget {
  final TransactionType transactionType;
  final OfferingData? offering;
  final QuoteData? quote;

  const PaymentFeeDetails({
    required this.transactionType,
    this.offering,
    this.quote,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final paymentDetails = offering ?? quote;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(15),
      ),
      padding:
          const EdgeInsets.only(left: Grid.xs, right: Grid.xs, top: Grid.xs),
      child: Column(
        children: [
          _buildRow(
            context,
            quote != null
                ? Loc.of(context).exchangeRate
                : Loc.of(context).estRate,
            '1 ${paymentDetails.payinCurrency} = ${paymentDetails.exchangeRate} ${paymentDetails.payoutCurrency}',
          ),
          _buildRow(
            context,
            Loc.of(context).serviceFee,
            '${paymentDetails.payinFee} ${paymentDetails.payinCurrency}',
          ),
          if (quote != null)
            _buildRow(
              context,
              Loc.of(context).total,
              '${calculateTotalAmount(quote)} ${paymentDetails.payinCurrency}',
              isBold: true,
            ),
        ],
      ),
    );
  }

  static String calculateTotalAmount(QuoteData? quote) =>
      Decimal.parse(quote?.payin.total ?? '0')
          .formatCurrency(quote?.payin.currencyCode ?? '');

  Widget _buildRow(
    BuildContext context,
    String title,
    String value, {
    bool isBold = false,
  }) =>
      Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight:
                            isBold ? FontWeight.bold : FontWeight.normal,
                      ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight:
                            isBold ? FontWeight.bold : FontWeight.normal,
                      ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: Grid.xs),
        ],
      );
}

extension _PaymentDetailsOperations on Object? {
  String? get payinCurrency => this is QuoteData
      ? (this as QuoteData?)?.payin.currencyCode
      : this is OfferingData
          ? (this as OfferingData?)?.payin.currencyCode
          : null;

  String? get payoutCurrency => this is QuoteData
      ? (this as QuoteData?)?.payout.currencyCode
      : this is OfferingData
          ? (this as OfferingData?)?.payout.currencyCode
          : null;

  String? get exchangeRate => this is QuoteData
      ? (this as QuoteData?)?.payoutUnitsPerPayinUnit
      : this is OfferingData
          ? (this as OfferingData?)?.payoutUnitsPerPayinUnit
          : null;

  String? get payinFee => this is QuoteData
      ? (this as QuoteData?)?.payin.fee
      : this is OfferingData
          ? (this as OfferingData?)?.payin.methods.firstOrNull?.fee ?? '0'
          : null;
}
