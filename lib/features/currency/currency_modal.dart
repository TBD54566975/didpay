import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:tbdex/tbdex.dart';

class CurrencyModal {
  static Future<dynamic> show(
    BuildContext context,
    TransactionType transactionType,
    ValueNotifier<Pfi?> selectedPfi,
    ValueNotifier<Offering?> selectedOffering,
    Map<Pfi, List<Offering>> offeringsMap,
  ) =>
      showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (context) => SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalOfferings = offeringsMap.values
                  .fold(0, (total, list) => total + list.length);
              final height = totalOfferings * Grid.tileHeight;
              final maxHeight = MediaQuery.of(context).size.height * 0.4;

              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: maxHeight,
                  minHeight: height < maxHeight ? height : maxHeight,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Grid.xs),
                      child: Text(
                        'Select currency',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Flexible(
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: ListView(
                          shrinkWrap: true,
                          children: offeringsMap.entries
                              .expand(
                                (entry) => entry.value.map(
                                  (offering) => ListTile(
                                    onTap: () {
                                      selectedPfi.value = entry.key;
                                      selectedOffering.value = offering;
                                      Navigator.pop(context);
                                    },
                                    title: _buildCurrencyTitle(
                                      context,
                                      offering,
                                      transactionType,
                                    ),
                                    subtitle: _buildCurrencySubtitle(
                                      context,
                                      offering,
                                      transactionType,
                                    ),
                                    trailing:
                                        (selectedOffering.value == offering)
                                            ? const Icon(Icons.check)
                                            : null,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

  static Widget _buildCurrencyTitle(
    BuildContext context,
    Offering offering,
    TransactionType transactionType,
  ) =>
      Text(
        '${offering.data.payin.currencyCode} → ${offering.data.payout.currencyCode}',
        style: Theme.of(context).textTheme.titleMedium,
      );

  static Widget _buildCurrencySubtitle(
    BuildContext context,
    Offering offering,
    TransactionType transactionType,
  ) =>
      Text(
        '1 ${offering.data.payin.currencyCode} = ${offering.data.payoutUnitsPerPayinUnit} ${offering.data.payout.currencyCode}',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
      );
}
