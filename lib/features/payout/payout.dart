import 'package:auto_size_text/auto_size_text.dart';
import 'package:decimal/decimal.dart';
import 'package:didpay/features/currency/currency_dropdown.dart';
import 'package:didpay/features/payment/payment_amount_state.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/currency_formatter.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Payout extends HookWidget {
  final TransactionType transactionType;
  final ValueNotifier<PaymentAmountState?> state;

  const Payout({required this.transactionType, required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final currencyCode = state.value?.payoutCurrency ?? '';
    final formattedAmount = Decimal.parse(state.value?.payoutAmount ?? '0')
        .formatCurrency(currencyCode);

    useEffect(
      () {
        final exchangeRate =
            Decimal.tryParse(state.value?.exchangeRate ?? '') ?? Decimal.one;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state.value?.selectedOffering == null) return;

          state.value = state.value?.copyWith(
            payoutAmount: ((state.value?.payinDecimalAmount ?? Decimal.zero) *
                    exchangeRate)
                .toString(),
          );
        });

        return;
      },
      [state.value?.payinAmount],
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
    switch (transactionType) {
      case TransactionType.withdraw:
        return CurrencyDropdown(
          paymentCurrency: state.value?.payinCurrency ?? '',
          state: state,
        );
      case TransactionType.deposit:
      case TransactionType.send:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Grid.xxs),
          child: Text(
            state.value?.payoutCurrency ?? '',
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

    final label = labels[transactionType] ?? 'unknown transaction type';

    return Text(label, style: style);
  }
}
