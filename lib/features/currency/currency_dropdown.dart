import 'package:didpay/features/modals/modal_select_currency.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

class CurrencyDropdown extends HookConsumerWidget {
  final PaymentState paymentState;
  final void Function(Pfi, Offering) onCurrencySelect;

  const CurrencyDropdown({
    required this.paymentState,
    required this.onCurrencySelect,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) => Directionality(
        textDirection: TextDirection.rtl,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.keyboard_arrow_down),
          label: _buildCurrencyLabel(context),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.only(left: Grid.xxs),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          onPressed: () => ModalSelectCurrency.show(
            context,
            paymentState,
            onCurrencySelect,
          ),
        ),
      );

  Widget _buildCurrencyLabel(BuildContext context) => Text(
        paymentState.transactionType == TransactionType.deposit
            ? paymentState.selectedOffering?.data.payin.currencyCode ?? ''
            : paymentState.selectedOffering?.data.payout.currencyCode ?? '',
        style: Theme.of(context).textTheme.headlineMedium,
      );
}
