import 'package:auto_size_text/auto_size_text.dart';
import 'package:decimal/decimal.dart';
import 'package:didpay/features/currency/currency_dropdown.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/currency_formatter.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tbdex/tbdex.dart';

class Payout extends HookWidget {
  final PaymentState paymentState;
  final ValueNotifier<Decimal> payoutAmount;
  final void Function(Pfi, Offering) onCurrencySelect;

  const Payout({
    required this.paymentState,
    required this.payoutAmount,
    required this.onCurrencySelect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final currencyCode = paymentState.payoutCurrency ?? '';
    final formattedAmount = Decimal.parse(payoutAmount.value.toString())
        .formatCurrency(currencyCode);

    useEffect(
      () {
        final exchangeRate =
            Decimal.tryParse(paymentState.rate ?? '') ?? Decimal.one;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (paymentState.offering == null) return;

          payoutAmount.value =
              Decimal.parse(paymentState.payinAmount ?? '0') * exchangeRate;
        });

        return;
      },
      [paymentState.payinAmount],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: AutoSizeText(
                formattedAmount,
                style: Theme.of(context).textTheme.displayMedium,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: Grid.half),
            _buildPayoutCurrency(context),
          ],
        ),
        const SizedBox(height: Grid.xs),
        _buildPayoutLabel(context),
      ],
    );
  }

  Widget _buildPayoutCurrency(BuildContext context) {
    switch (paymentState.transactionType) {
      case TransactionType.withdraw:
        return CurrencyDropdown(
          paymentState: paymentState,
          onCurrencySelect: onCurrencySelect,
        );
      case TransactionType.deposit:
      case TransactionType.send:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Grid.xxs),
          child: Text(
            paymentState.payoutCurrency ?? '',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        );
    }
  }

  Widget _buildPayoutLabel(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyLarge;
    final labels = {
      TransactionType.deposit: Loc.of(context).youDeposit,
      TransactionType.withdraw: Loc.of(context).youGet,
      TransactionType.send: Loc.of(context).theyGet,
    };

    final label =
        labels[paymentState.transactionType] ?? 'unknown transaction type';

    return Text(label, style: style);
  }
}
