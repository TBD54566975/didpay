import 'package:didpay/features/kcc/lib.dart';
import 'package:didpay/features/vcs/vcs_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockBox mockBox;

  setUp(() {
    mockBox = MockBox();
  });

  group('VcsNotifier', () {
    test('should create and load initial list', () async {
      final initialVcs = ['fake_cred'];

      when(() => mockBox.get(VcsNotifier.storageKey)).thenReturn(initialVcs);
      final notifier = await VcsNotifier.create(mockBox);

      expect(notifier.state, initialVcs);
      verify(() => mockBox.get(VcsNotifier.storageKey)).called(1);
    });

    test('should add a new credential', () async {
      final initialVcs = ['fake_cred'];
      const newVc = 'new_cred';

      when(() => mockBox.get(VcsNotifier.storageKey)).thenReturn(initialVcs);
      when(
        () => mockBox.put(
          VcsNotifier.storageKey,
          any<List<Map<String, dynamic>>>(),
        ),
      ).thenAnswer((_) async {});

      final notifier = await VcsNotifier.create(mockBox);

      final addedVc = await notifier
          .add(CredentialResponse(credential: newVc, transactionId: null));

      expect(notifier.state, [...initialVcs, newVc]);
      expect(addedVc, newVc);

      verify(
        () => mockBox.put(
          VcsNotifier.storageKey,
          [...initialVcs, newVc],
        ),
      ).called(1);
    });

    test('should remove a credential', () async {
      final initialVcs = ['fake_cred'];
      final credentialToRemove = initialVcs.first;

      when(() => mockBox.get(VcsNotifier.storageKey)).thenReturn(initialVcs);
      when(() => mockBox.put(VcsNotifier.storageKey, any()))
          .thenAnswer((_) async {});

      final notifier = await VcsNotifier.create(mockBox);
      await notifier.remove(credentialToRemove);

      expect(notifier.state, []);
      verify(() => mockBox.put(VcsNotifier.storageKey, [])).called(1);
    });
  });
}
