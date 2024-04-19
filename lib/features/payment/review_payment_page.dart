import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/features/payment/payment_confirmation_page.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/fee_details.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:didpay/shared/utils/currency_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ReviewPaymentPage extends HookWidget {
  final String payinAmount;
  final String payoutAmount;
  final String payinCurrency;
  final String payoutCurrency;
  final String exchangeRate;
  final String serviceFee;
  final String paymentName;
  final TransactionType transactionType;
  final Map<String, String> formData;

  const ReviewPaymentPage({
    required this.payinAmount,
    required this.payoutAmount,
    required this.payinCurrency,
    required this.payoutCurrency,
    required this.exchangeRate,
    required this.serviceFee,
    required this.paymentName,
    required this.transactionType,
    required this.formData,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Grid.side),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Grid.sm),
                      _buildAmounts(context),
                      _buildFeeDetails(context),
                      _buildPaymentDetails(context),
                    ],
                  ),
                ),
              ),
              _buildSubmitButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: Grid.xs),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                Loc.of(context).reviewYourPayment,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: Grid.xs),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                Loc.of(context).makeSureInfoIsCorrect,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );

  Widget _buildAmounts(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: AutoSizeText(
                  CurrencyUtil.formatFromString(
                    payinAmount,
                    currency: payinCurrency.toUpperCase(),
                  ),
                  style: Theme.of(context).textTheme.headlineMedium,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: Grid.half),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Grid.xxs),
                child: Text(
                  payinCurrency,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: Grid.xxs),
          _buildPayinLabel(context),
          const SizedBox(height: Grid.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: AutoSizeText(
                  payoutAmount,
                  style: Theme.of(context).textTheme.headlineMedium,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: Grid.xs),
              Text(
                payoutCurrency,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: Grid.xxs),
          _buildPayoutLabel(context),
        ],
      );

  Widget _buildPayinLabel(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    final labels = {
      TransactionType.deposit: Loc.of(context).youPay,
      TransactionType.withdraw: Loc.of(context).withdrawAmount,
      TransactionType.send: Loc.of(context).youSend,
    };

    final label = labels[transactionType] ?? 'unknown transaction type';

    return Text(label, style: style);
  }

  Widget _buildPayoutLabel(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    final labels = {
      TransactionType.deposit: Loc.of(context).depositAmount,
      TransactionType.withdraw: Loc.of(context).youGet,
      TransactionType.send: Loc.of(context).theyGet,
    };

    final label = labels[transactionType] ?? 'unknown transaction type';

    return Text(label, style: style);
  }

  Widget _buildFeeDetails(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: Grid.lg),
        child: FeeDetails(
          payinCurrency: Loc.of(context).usd,
          payoutCurrency: payinCurrency != Loc.of(context).usd
              ? payinCurrency
              : payoutCurrency,
          exchangeRate: exchangeRate,
          serviceFee: double.parse(serviceFee).toStringAsFixed(2),
          total: payinCurrency != Loc.of(context).usd
              ? (double.parse(payinAmount.replaceAll(',', '')) +
                      double.parse(serviceFee))
                  .toStringAsFixed(2)
              : (double.parse(payoutAmount.replaceAll(',', '')) +
                      double.parse(serviceFee))
                  .toStringAsFixed(2),
        ),
      );

  Widget _buildPaymentDetails(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: Grid.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(paymentName, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: Grid.xxs),
            ...formData.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(
                  bottom: Grid.xxs,
                ),
                child: Text(
                  entry.value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildSubmitButton(BuildContext context) => FilledButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const PaymentConfirmationPage(),
            ),
          );
        },
        child: Text(Loc.of(context).submit),
      );
}
