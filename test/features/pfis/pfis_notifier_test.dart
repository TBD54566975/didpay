import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() async {
  await TestData.initializeDids();

  final initialPfi = TestData.getPfi('did:dht:pfiDid');
  final newPfi = TestData.getPfi('did:dht:newDid');
  final initialPfis = [initialPfi];

  late MockBox mockBox;
  late MockPfisService mockPfisService;

  setUp(() {
    mockBox = MockBox();
    mockPfisService = MockPfisService();
  });

  group('PfisNotifier', () {
    test('should create and load initial list', () async {
      when(() => mockBox.get(PfisNotifier.storageKey))
          .thenReturn(initialPfis.map((pfi) => pfi.toJson()).toList());
      final notifier = await PfisNotifier.create(mockBox, mockPfisService);

      expect(notifier.state, initialPfis);

      verify(() => mockBox.get(PfisNotifier.storageKey)).called(1);
    });

    test('should add a new Pfi', () async {
      when(() => mockBox.get(PfisNotifier.storageKey))
          .thenReturn(initialPfis.map((pfi) => pfi.toJson()).toList());
      when(
        () => mockBox.put(
          PfisNotifier.storageKey,
          any<List<Map<String, dynamic>>>(),
        ),
      ).thenAnswer((_) async {});
      when(() => mockPfisService.createPfi(newPfi.did))
          .thenAnswer((_) async => newPfi);

      final notifier = await PfisNotifier.create(mockBox, mockPfisService);

      final addedPfi = await notifier.add(newPfi.did);

      expect(notifier.state, [...initialPfis, newPfi]);
      expect(addedPfi, newPfi);

      verify(
        () => mockBox.put(
          PfisNotifier.storageKey,
          [...initialPfis.map((pfi) => pfi.toJson()), newPfi.toJson()],
        ),
      ).called(1);
      verify(() => mockPfisService.createPfi(newPfi.did)).called(1);
    });

    test('should remove a Pfi', () async {
      final pfiToRemove = initialPfis.first;

      when(() => mockBox.get(PfisNotifier.storageKey))
          .thenReturn(initialPfis.map((pfi) => pfi.toJson()).toList());
      when(
        () => mockBox.put(
          PfisNotifier.storageKey,
          any<List<Map<String, dynamic>>>(),
        ),
      ).thenAnswer((_) async {});

      final notifier = await PfisNotifier.create(mockBox, mockPfisService);
      await notifier.remove(pfiToRemove);

      expect(notifier.state, []);
      verify(() => mockBox.put(PfisNotifier.storageKey, [])).called(1);
    });
  });
}
