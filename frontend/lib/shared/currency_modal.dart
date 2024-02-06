import 'package:flutter/material.dart';
import 'package:flutter_starter/shared/grid.dart';

class CurrencyModal {
  static Future<dynamic> showCurrencyModal(
      BuildContext context,
      Function(String) onPressed,
      List<Map<String, Object>> supportedCurrencyList,
      String selectedCurrency) {
    return showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
              child: SizedBox(
            height: supportedCurrencyList.length * 80,
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
                    children:
                        supportedCurrencyList.map((Map<String, Object> map) {
                  IconData icon = map['icon'] as IconData;
                  String label = map['label'].toString();
                  return (ListTile(
                    onTap: () {
                      onPressed(label);
                      Navigator.pop(context);
                    },
                    leading: Icon(icon),
                    title: Text(label,
                        style: Theme.of(context).textTheme.titleMedium),
                    trailing: (selectedCurrency == label)
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
