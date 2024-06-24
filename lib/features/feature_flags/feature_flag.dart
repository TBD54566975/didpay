import 'package:equatable/equatable.dart';

class FeatureFlag extends Equatable {
  final String name;
  final String description;
  final bool isEnabled;

  const FeatureFlag({
    required this.name,
    required this.description,
    this.isEnabled = false,
  });

  factory FeatureFlag.fromJson(Map<String, dynamic> json) => FeatureFlag(
        name: json['name'],
        description: json['description'],
        isEnabled: json['isEnabled'],
      );

  Map<String, dynamic> toJson() =>
      {'name': name, 'description': description, 'isEnabled': isEnabled};

  FeatureFlag copyWith({String? name, String? description, bool? isEnabled}) =>
      FeatureFlag(
        name: name ?? this.name,
        description: description ?? this.description,
        isEnabled: isEnabled ?? this.isEnabled,
      );

  @override
  List<Object?> get props => [name, description, isEnabled];
}

const lucidMode = FeatureFlag(
  name: 'Lucid mode',
  description: 'Access all your PFI offerings',
);

const remittance = FeatureFlag(
  name: 'Remittance',
  description: 'Experience a tranditional remittance flow',
);
