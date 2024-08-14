import 'package:didpay/features/payment/payment_amount_state.dart';
import 'package:didpay/l10n/app_localizations.dart';
import 'package:didpay/shared/theme/grid.dart';
import 'package:flutter/material.dart';
import 'package:tbdex/tbdex.dart';

class ModalSelectCurrency {
  static Future<dynamic> show(
    BuildContext context,
    ValueNotifier<PaymentAmountState?> state,
  ) =>
      showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (context) => SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (state.value?.offeringsMap == null) return Container();

              final totalOfferings = state.value!.offeringsMap!.values
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
                        Loc.of(context).selectCurrency,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Flexible(
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: ListView(
                          shrinkWrap: true,
                          children: state.value!.offeringsMap!.entries
                              .expand(
                                (entry) => entry.value.map(
                                  (offering) => ListTile(
                                    onTap: () {
                                      state.value = state.value?.copyWith(
                                        selectedOffering: offering,
                                        pfiDid: entry.key.did,
                                      );
                                      Navigator.pop(context);
                                    },
                                    title: _buildCurrencyTitle(
                                      context,
                                      offering,
                                    ),
                                    subtitle: _buildCurrencySubtitle(
                                      context,
                                      offering,
                                    ),
                                    trailing: (state.value?.selectedOffering ==
                                            offering)
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
  ) =>
      Text(
        '${offering.data.payin.currencyCode} → ${offering.data.payout.currencyCode}',
        style: Theme.of(context).textTheme.titleMedium,
      );

  static Widget _buildCurrencySubtitle(
    BuildContext context,
    Offering offering,
  ) =>
      Text(
        '1 ${offering.data.payin.currencyCode} = ${offering.data.payoutUnitsPerPayinUnit} ${offering.data.payout.currencyCode}',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
      );
}
