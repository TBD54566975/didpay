import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/currency/currency_dropdown.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/utils/currency_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tbdex/tbdex.dart';

class Payout extends HookWidget {
  final double payinAmount;
  final TransactionType transactionType;
  final ValueNotifier<double> payoutAmount;
  final ValueNotifier<Pfi?> selectedPfi;
  final ValueNotifier<Offering?> selectedOffering;
  final Map<Pfi, List<Offering>> offeringsMap;

  const Payout({
    required this.payinAmount,
    required this.transactionType,
    required this.payoutAmount,
    required this.selectedPfi,
    required this.selectedOffering,
    required this.offeringsMap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = transactionType == TransactionType.withdraw
        ? CurrencyUtil.formatFromDouble(
            payoutAmount.value,
            currency: selectedOffering.value?.data.payout.currencyCode,
          )
        : CurrencyUtil.formatFromDouble(payoutAmount.value);

    useEffect(
      () {
        final exchangeRate = double.tryParse(
              selectedOffering.value?.data.payoutUnitsPerPayinUnit ?? '',
            ) ??
            1;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (selectedOffering.value == null) return;

          payoutAmount.value = payinAmount * exchangeRate;
        });

        return;
      },
      [payinAmount],
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
          transactionType: transactionType,
          selectedPfi: selectedPfi,
          selectedOffering: selectedOffering,
          offeringsMap: offeringsMap,
        );
      case TransactionType.deposit:
      case TransactionType.send:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Grid.xxs),
          child: Text(
            selectedOffering.value?.data.payout.currencyCode ?? '',
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
