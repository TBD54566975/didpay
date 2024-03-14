import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/currency/currency.dart';
import 'package:didpay/features/currency/currency_dropdown.dart';
import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Payout extends HookWidget {
  final double payinAmount;
  final TransactionType transactionType;
  final ValueNotifier<double> payoutAmount;
  final ValueNotifier<Currency?> currency;

  const Payout({
    required this.payinAmount,
    required this.transactionType,
    required this.payoutAmount,
    required this.currency,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = transactionType == TransactionType.withdraw
        ? Currency.formatFromDouble(
            payoutAmount.value,
            currency: currency.value?.code,
          )
        : Currency.formatFromDouble(payoutAmount.value);

    useEffect(() {
      final exchangeRate = currency.value?.exchangeRate ?? 1.0;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (currency.value == null) return;

        payoutAmount.value = transactionType == TransactionType.deposit
            ? payinAmount / exchangeRate
            : payinAmount * exchangeRate;
      });

      return;
    }, [payinAmount]);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
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
            transactionType == TransactionType.withdraw
                ? CurrencyDropdown(selectedCurrency: currency)
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Grid.xxs),
                    child: Text(
                      '${CurrencyCode.usdc}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
          ],
        ),
        const SizedBox(height: Grid.xs),
        Text(
          Loc.of(context).youGet,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
