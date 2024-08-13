import 'package:didpay/features/feature_flags/feature_flag.dart';
import 'package:didpay/shared/serializer.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final featureFlagsProvider =
    StateNotifierProvider<FeatureFlagsNotifier, List<FeatureFlag>>(
  (ref) => throw UnimplementedError(),
);

class FeatureFlagsNotifier extends StateNotifier<List<FeatureFlag>> {
  static const String storageKey = 'feature_flags';
  final Box box;

  FeatureFlagsNotifier._(this.box, List<FeatureFlag> state) : super(state);

  static Future<FeatureFlagsNotifier> create(
    Box box,
  ) async {
    final List<dynamic> flagsJson = await box.get(storageKey) ?? [];

    return FeatureFlagsNotifier._(
        box, Serializer.deserializeList(flagsJson, FeatureFlag.fromJson));
  }

  Future<FeatureFlag> add(FeatureFlag flag) async {
    state = [
      ...state,
      FeatureFlag(name: flag.name, description: flag.description),
    ];

    await _save();
    return flag;
  }

  Future<void> remove(FeatureFlag flag) async {
    state = state.where((elem) => elem != flag).toList();
    await _save();
  }

  Future<void> toggleFlag(FeatureFlag flag) async {
    state = state
        .map((f) => f == flag ? f.copyWith(isEnabled: !f.isEnabled) : f)
        .toList();
    await _save();
  }

  Future<void> _save() async {
    final featureFlags =
        Serializer.serializeList(state, (flag) => flag.toJson());
    await box.put(storageKey, featureFlags);
  }
}
