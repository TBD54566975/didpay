import 'package:didpay/features/currency/currency.dart';
import 'package:flutter/material.dart';
import 'package:didpay/shared/theme/grid.dart';

class CurrencyModal {
  static Future<dynamic> show(BuildContext context, Function(String) onPressed,
      List<Currency> currencies, String selectedCurrency) {
    return showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
              child: SizedBox(
            height: currencies.length * 80,
            child: Column(children: [
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: Grid.xs),
                  child: Text(
                    'Select currency',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  )),
              Expanded(
                child: ListView(
                    children: currencies.map((Currency c) {
                  return (ListTile(
                    onTap: () {
                      onPressed(c.label);
                      Navigator.pop(context);
                    },
                    leading: Icon(c.icon),
                    title: Text(c.label,
                        style: Theme.of(context).textTheme.titleMedium),
                    trailing: (selectedCurrency == c.label)
                        ? const Icon(Icons.check)
                        : null,
                  ));
                }).toList()),
              )
            ]),
          ));
        });
  }
}
