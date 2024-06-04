import 'package:didpay/features/modals/modal_select_currency.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';

class CurrencyDropdown extends HookConsumerWidget {
  final TransactionType transactionType;
  final ValueNotifier<Pfi?> selectedPfi;
  final ValueNotifier<Offering?> selectedOffering;
  final Map<Pfi, List<Offering>> offeringsMap;

  const CurrencyDropdown({
    required this.transactionType,
    required this.selectedPfi,
    required this.selectedOffering,
    required this.offeringsMap,
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
            transactionType,
            selectedPfi,
            selectedOffering,
            offeringsMap,
          ),
        ),
      );

  Widget _buildCurrencyLabel(BuildContext context) => Text(
        transactionType == TransactionType.deposit
            ? selectedOffering.value?.data.payin.currencyCode ?? ''
            : selectedOffering.value?.data.payout.currencyCode ?? '',
        style: Theme.of(context).textTheme.headlineMedium,
      );
}
