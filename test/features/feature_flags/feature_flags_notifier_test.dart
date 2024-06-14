import 'package:didpay/features/feature_flags/feature_flag.dart';
import 'package:didpay/features/feature_flags/feature_flags_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockBox mockBox;

  setUp(() {
    mockBox = MockBox();
  });

  group('FeatureFlagsNotifier', () {
    test('should create and load initial list', () async {
      final initialFeatureFlags = [
        const FeatureFlag(name: 'test', description: 'test flag'),
      ];

      when(() => mockBox.get(FeatureFlagsNotifier.storageKey)).thenReturn(
        initialFeatureFlags.map((flag) => flag.toJson()).toList(),
      );
      final notifier = await FeatureFlagsNotifier.create(mockBox);

      expect(notifier.state, initialFeatureFlags);
      verify(() => mockBox.get(FeatureFlagsNotifier.storageKey)).called(1);
    });

    test('should add a new FeatureFlag', () async {
      final initialFeatureFlags = [
        const FeatureFlag(name: 'test', description: 'test flag'),
      ];
      const newFeatureFlag =
          FeatureFlag(name: 'new test', description: 'new test flag');

      when(() => mockBox.get(FeatureFlagsNotifier.storageKey)).thenReturn(
          initialFeatureFlags.map((flag) => flag.toJson()).toList(),);
      when(
        () => mockBox.put(
          FeatureFlagsNotifier.storageKey,
          any<List<Map<String, dynamic>>>(),
        ),
      ).thenAnswer((_) async {});

      final notifier = await FeatureFlagsNotifier.create(mockBox);

      final addedFeatureFlag = await notifier.add(newFeatureFlag);

      expect(notifier.state, [...initialFeatureFlags, newFeatureFlag]);
      expect(addedFeatureFlag, newFeatureFlag);

      verify(
        () => mockBox.put(
          FeatureFlagsNotifier.storageKey,
          [
            ...initialFeatureFlags.map((flag) => flag.toJson()),
            newFeatureFlag.toJson(),
          ],
        ),
      ).called(1);
    });

    test('should remove a FeatureFlag', () async {
      final initialFeatureFlags = [
        const FeatureFlag(name: 'test', description: 'test flag'),
      ];
      final featureFlagToRemove = initialFeatureFlags.first;

      when(() => mockBox.get(FeatureFlagsNotifier.storageKey)).thenReturn(
        initialFeatureFlags.map((flag) => flag.toJson()).toList(),
      );
      when(() => mockBox.put(FeatureFlagsNotifier.storageKey, any()))
          .thenAnswer((_) async {});

      final notifier = await FeatureFlagsNotifier.create(mockBox);
      await notifier.remove(featureFlagToRemove);

      expect(notifier.state, []);
      verify(() => mockBox.put(FeatureFlagsNotifier.storageKey, [])).called(1);
    });
  });
}
