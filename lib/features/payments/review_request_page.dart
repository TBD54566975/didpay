import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/fee_details.dart';
import 'package:didpay/shared/success_page.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

class ReviewRequestPage extends HookWidget {
  final String inputAmount;
  final String outputAmount;
  final String inputCurrency;
  final String outputCurrency;
  final String exchangeRate;
  final String serviceFee;
  final String bankName;
  final Map<String, String> formData;
  final String transactionType;

  const ReviewRequestPage({
    required this.inputAmount,
    required this.outputAmount,
    required this.inputCurrency,
    required this.outputCurrency,
    required this.exchangeRate,
    required this.serviceFee,
    required this.bankName,
    required this.formData,
    required this.transactionType,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHeader(context),
                                const SizedBox(height: Grid.md),
                                _buildAmounts(context),
                                const SizedBox(height: Grid.md),
                                _buildFeeDetails(context),
                                const SizedBox(height: Grid.md),
                                _buildBankDetails(context),
                              ])),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SuccessPage(
                                  text: Loc.of(context).yourRequestWasSubmitted,
                                ),
                              ),
                            );
                          },
                          child: Text(Loc.of(context).submit),
                        ),
                      ],
                    ),
                  ],
                ))));
  }

  Widget _buildHeader(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          Loc.of(context).reviewYourRequest,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: Grid.xs),
        Text(Loc.of(context).makeSureInfoIsCorrect,
            style: Theme.of(context).textTheme.bodyLarge),
      ]);

  Widget _buildAmounts(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              NumberFormat.simpleCurrency().format(double.parse(inputAmount)),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(width: Grid.xs),
            Text(
              inputCurrency,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        const SizedBox(height: Grid.xxs),
        Text(
          transactionType == Type.deposit
              ? Loc.of(context).youPay
              : Loc.of(context).withdrawAmount,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: Grid.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              NumberFormat.simpleCurrency().format(double.parse(outputAmount)),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(width: Grid.xs),
            Text(
              outputCurrency,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        const SizedBox(height: Grid.xxs),
        Text(
          transactionType == Type.deposit
              ? Loc.of(context).depositAmount
              : Loc.of(context).youGet,
          style: Theme.of(context).textTheme.bodyLarge,
        )
      ]);

  Widget _buildFeeDetails(BuildContext context) => FeeDetails(
      originCurrency: Loc.of(context).usd,
      destinationCurrency:
          inputCurrency != Loc.of(context).usd ? inputCurrency : outputCurrency,
      exchangeRate: exchangeRate,
      serviceFee: double.parse(serviceFee).toStringAsFixed(2),
      total: inputCurrency != Loc.of(context).usd
          ? (double.parse(inputAmount) + double.parse(serviceFee))
              .toStringAsFixed(2)
          : (double.parse(outputAmount) + double.parse(serviceFee))
              .toStringAsFixed(2));

  Widget _buildBankDetails(BuildContext context) => Column(children: [
        Text(bankName),
        const SizedBox(height: Grid.xxs),
        Text(obscureAccountNumber(formData['accountNumber']!)),
      ]);

  String obscureAccountNumber(String input) {
    if (input.length <= 4) {
      return input;
    }
    return '${'•' * (input.length - 4)} ${input.substring(input.length - 4)}';
  }
}
