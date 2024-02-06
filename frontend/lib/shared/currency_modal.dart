import 'package:flutter/material.dart';
import 'package:flutter_starter/shared/grid.dart';

class CurrencyModal {
  static Future<dynamic> showCurrencyModal(
      BuildContext context,
      Function(String) onPressed,
      List<Map<String, Object>> supportedCurrencyList) {
    return showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: 200,
            child: Center(
              child: ListView(
                children: supportedCurrencyList.map((Map<String, Object> map) {
                  IconData icon = map['icon'] as IconData;
                  String label = map['label'].toString();
                  return TextButton(
                      onPressed: () {
                        onPressed(label);
                        Navigator.pop(context);
                      },
                      child: Row(children: [
                        Icon(icon),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Grid.side, vertical: Grid.xs),
                            child: Text(label,
                                style: Theme.of(context).textTheme.titleMedium),
                          ),
                        )
                      ]));
                }).toList(),
              ),
            ),
          );
        });
  }
}
