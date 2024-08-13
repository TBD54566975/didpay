import 'package:didpay/features/feature_flags/feature_flags_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() {
  final testFlag = TestData.getFeatureFlag('test', 'test description');
  final newFlag = TestData.getFeatureFlag('new test', 'new test description');
  final initialFeatureFlags = [testFlag];

  late MockBox mockBox;

  setUp(() {
    mockBox = MockBox();
  });

  group('FeatureFlagsNotifier', () {
    test('should create and load initial list', () async {
      when(() => mockBox.get(FeatureFlagsNotifier.storageKey)).thenReturn(
        initialFeatureFlags.map((flag) => flag.toJson()).toList(),
      );
      when(
        () => mockBox.put(
          FeatureFlagsNotifier.storageKey,
          any<List<Map<String, dynamic>>>(),
        ),
      ).thenAnswer((_) async {});

      final notifier = await FeatureFlagsNotifier.create(mockBox);

      expect(notifier.state, initialFeatureFlags);
      verify(() => mockBox.get(FeatureFlagsNotifier.storageKey)).called(1);
    });

    test('should add a new FeatureFlag', () async {
      when(() => mockBox.get(FeatureFlagsNotifier.storageKey)).thenReturn(
        initialFeatureFlags.map((flag) => flag.toJson()).toList(),
      );
      when(
        () => mockBox.put(
          FeatureFlagsNotifier.storageKey,
          any<List<Map<String, dynamic>>>(),
        ),
      ).thenAnswer((_) async {});

      final notifier = await FeatureFlagsNotifier.create(mockBox);

      final addedFeatureFlag = await notifier.add(newFlag);

      expect(notifier.state, [...initialFeatureFlags, newFlag]);
      expect(addedFeatureFlag, newFlag);

      verify(
        () => mockBox.put(
          FeatureFlagsNotifier.storageKey,
          [
            ...initialFeatureFlags.map((flag) => flag.toJson()),
            newFlag.toJson(),
          ],
        ),
      ).called(1);
    });

    test('should remove a FeatureFlag', () async {
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
