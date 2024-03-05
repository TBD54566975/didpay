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
                      onPressed(c.code.toString());
                      Navigator.pop(context);
                    },
                    leading: Icon(c.icon),
                    title: Text('${c.code}',
                        style: Theme.of(context).textTheme.titleMedium),
                    trailing: (selectedCurrency == c.code.toString())
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
