import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:tbdex/tbdex.dart';

class CurrencyModal {
  static Future<dynamic> show(
    BuildContext context,
    TransactionType transactionType,
    ValueNotifier<Offering?> selectedOffering,
    List<Offering> offerings,
  ) =>
      showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (context) => SafeArea(
          child: SizedBox(
            height: 100 + (offerings.length * 30),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Grid.xs),
                  child: Text(
                    'Select currency',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: offerings.map((offering) {
                      return ListTile(
                        onTap: () {
                          selectedOffering.value = offering;
                          Navigator.pop(context);
                        },
                        // leading: Icon(c.icon),
                        title: _buildCurrencyTitle(
                          context,
                          offering,
                          transactionType,
                        ),
                        subtitle: Text(
                          offering.data.payoutUnitsPerPayinUnit,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                        trailing: (selectedOffering.value == offering)
                            ? const Icon(Icons.check)
                            : null,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  static Widget _buildCurrencyTitle(
    BuildContext context,
    Offering offering,
    TransactionType transactionType,
  ) =>
      Text(
        transactionType == TransactionType.deposit
            ? offering.data.payin.currencyCode
            : offering.data.payout.currencyCode,
        style: Theme.of(context).textTheme.titleMedium,
      );
}
