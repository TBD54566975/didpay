import 'package:didpay/features/currency/currency_modal.dart';
import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

class CurrencyDropdown extends HookConsumerWidget {
  final TransactionType transactionType;
  final ValueNotifier<Offering?> selectedOffering;
  final List<Offering> offerings;

  const CurrencyDropdown({
    required this.transactionType,
    required this.selectedOffering,
    required this.offerings,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.keyboard_arrow_down),
        label: _buildCurrencyLabel(context),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.only(left: Grid.xxs),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        onPressed: () {
          CurrencyModal.show(
            context,
            transactionType,
            selectedOffering,
            offerings,
          );
        },
      ),
    );
  }

  Widget _buildCurrencyLabel(BuildContext context) => Text(
        transactionType == TransactionType.deposit
            ? selectedOffering.value?.data.payin.currencyCode ?? ''
            : selectedOffering.value?.data.payout.currencyCode ?? '',
        style: Theme.of(context).textTheme.headlineMedium,
      );
}
