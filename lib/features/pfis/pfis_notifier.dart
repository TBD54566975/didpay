import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_service.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final pfisProvider = StateNotifierProvider<PfisNotifier, List<Pfi>>(
  (ref) => throw UnimplementedError(),
);

class PfisNotifier extends StateNotifier<List<Pfi>> {
  static const String storageKey = 'pfis';
  final Box box;
  final PfisService pfiService;

  PfisNotifier._(this.box, this.pfiService, List<Pfi> state) : super(state);

  static Future<PfisNotifier> create(Box box, PfisService pfiService) async {
    final pfis = await box.get(storageKey);
    return PfisNotifier._(box, pfiService, pfis ?? []);
  }

  Future<Pfi> add(String input) async {
    final pfi = await pfiService.createPfi(input);
    await Future.delayed(const Duration(seconds: 1));

    state = [...state, pfi];
    await _save();
    return pfi;
  }

  Future<void> remove(Pfi pfi) async {
    state = state.where((elem) => elem.did != pfi.did).toList();
    await _save();
  }

  Future<void> _save() async {
    await box.put(storageKey, state);
  }
}
