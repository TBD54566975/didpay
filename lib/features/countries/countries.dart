import 'package:didpay/shared/theme/grid.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Country extends Equatable {
  final String name;
  final String code;

  const Country({
    required this.name,
    required this.code,
  });

  static Widget buildCountryTile(
    BuildContext context,
    Country country, {
    required bool isSelected,
    required VoidCallback onTap,
  }) =>
      ListTile(
        leading: Container(
          width: Grid.md,
          height: Grid.md,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(Grid.xxs),
          ),
          child: Center(
            child: _buildFlag(context, country.code),
          ),
        ),
        title: Text(country.name),
        onTap: onTap,
        selected: isSelected,
        trailing: isSelected
            ? Icon(
                Icons.check,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
      );

  static Widget _buildFlag(BuildContext context, String countryCode) {
    const asciiOffset = 0x41;
    const flagOffset = 0x1F1E6;

    final firstChar = countryCode.codeUnitAt(0) - asciiOffset + flagOffset;
    final secondChar = countryCode.codeUnitAt(1) - asciiOffset + flagOffset;

    var emoji =
        String.fromCharCode(firstChar) + String.fromCharCode(secondChar);

    return Text(
      emoji,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'code': code,
      };

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        name: json['name'],
        code: json['code'],
      );

  @override
  List<Object?> get props => [name, code];
}
