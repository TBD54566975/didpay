import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockBox mockBox;
  late MockPfisService mockPfisService;

  setUp(() {
    mockBox = MockBox();
    mockPfisService = MockPfisService();
  });

  group('PfisNotifier', () {
    test('should create and load initial list', () async {
      final initialPfis = [const Pfi(did: 'did:web:x%3A8892:ingress')];

      when(() => mockBox.get(PfisNotifier.storageKey)).thenReturn(initialPfis);
      final notifier = await PfisNotifier.create(mockBox, mockPfisService);

      expect(notifier.state, initialPfis);

      verify(() => mockBox.get(PfisNotifier.storageKey)).called(1);
    });

    test('should add a new Pfi', () async {
      final initialPfis = [const Pfi(did: 'did:web:x%3A8892:ingress')];
      const newPfi = Pfi(did: 'did:web:x%3A8892:egress');

      when(() => mockBox.get(PfisNotifier.storageKey)).thenReturn(initialPfis);
      when(() => mockBox.put(PfisNotifier.storageKey, any()))
          .thenAnswer((_) async {});
      when(() => mockPfisService.createPfi(newPfi.did))
          .thenAnswer((_) async => newPfi);

      final notifier = await PfisNotifier.create(mockBox, mockPfisService);

      final addedPfi = await notifier.add(newPfi.did);

      expect(notifier.state, [...initialPfis, newPfi]);
      expect(addedPfi, newPfi);

      verify(
        () => mockBox.put(PfisNotifier.storageKey, [...initialPfis, newPfi]),
      ).called(1);
      verify(() => mockPfisService.createPfi(newPfi.did)).called(1);
    });

    test('should remove a Pfi', () async {
      final initialPfis = [const Pfi(did: 'did:web:x%3A8892:ingress')];
      final pfiToRemove = initialPfis.first;

      when(() => mockBox.get(PfisNotifier.storageKey)).thenReturn(initialPfis);
      when(() => mockBox.put(PfisNotifier.storageKey, any()))
          .thenAnswer((_) async {});

      final notifier = await PfisNotifier.create(mockBox, mockPfisService);
      await notifier.remove(pfiToRemove);

      expect(notifier.state, []);
      verify(() => mockBox.put(PfisNotifier.storageKey, [])).called(1);
    });
  });
}
