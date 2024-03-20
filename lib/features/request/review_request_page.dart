import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/currency/currency.dart';
import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/features/request/request_confirmation_page.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/fee_details.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ReviewRequestPage extends HookWidget {
  final String payinAmount;
  final String payoutAmount;
  final String payinCurrency;
  final String payoutCurrency;
  final String exchangeRate;
  final String serviceFee;
  final String paymentName;
  final TransactionType transactionType;
  final Map<String, String> formData;

  const ReviewRequestPage({
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      _buildBankDetails(context),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RequestConfirmationPage(),
                        ),
                      );
                    },
                    child: Text(Loc.of(context).submit),
                  ),
                ],
              ),
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
                Loc.of(context).reviewYourRequest,
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
                  Currency.formatFromString(
                    payinAmount,
                    currency:
                        CurrencyCode.values.byName(payinCurrency.toLowerCase()),
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
          Text(
            transactionType == TransactionType.deposit
                ? Loc.of(context).youPay
                : Loc.of(context).withdrawAmount,
            style: Theme.of(context).textTheme.bodySmall,
          ),
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
          Text(
            transactionType == TransactionType.deposit
                ? Loc.of(context).depositAmount
                : Loc.of(context).youGet,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );

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

  Widget _buildBankDetails(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: Grid.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(paymentName, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: Grid.xxs),
            Text(
              _obscureAccountNumber(formData['accountNumber']!),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );

  String _obscureAccountNumber(String input) {
    if (input.length <= 4) {
      return input;
    }
    return '${'•' * (input.length - 4)} ${input.substring(input.length - 4)}';
  }
}
