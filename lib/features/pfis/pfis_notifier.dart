import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_service.dart';
import 'package:didpay/features/storage/storage_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final pfisProvider = StateNotifierProvider<PfisNotifier, List<Pfi>>(
  (ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final pfis = PfisNotifier.loadSavedPfiDids(prefs);
    return PfisNotifier(prefs, PfisService(), pfis);
  },
);

class PfisNotifier extends StateNotifier<List<Pfi>> {
  static const String prefsKey = 'pfis';
  final SharedPreferences prefs;
  final PfisService pfiService;

  PfisNotifier(this.prefs, this.pfiService, super.state);

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
    final toSave = state.map((e) => e.did).toList();
    await prefs.setStringList('pfis', toSave);
  }

  static List<Pfi> loadSavedPfiDids(SharedPreferences prefs) {
    final saved = prefs.getStringList(prefsKey);

    if (saved == null) {
      return [];
    }

    final pfis = <Pfi>[];
    for (final pfiDid in saved) {
      try {
        pfis.add(Pfi(did: pfiDid));
      } on Exception catch (e) {
        throw Exception('Failed to load saved PFI: $e');
      }
    }

    return pfis;
  }
}
