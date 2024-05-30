import 'package:didpay/features/kcc/lib.dart';
import 'package:didpay/features/storage/storage_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final vcsProvider = StateNotifierProvider<VcsNotifier, List<String>>(
  (ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final vcs = VcsNotifier.loadSavedVcJwts(prefs);
    return VcsNotifier(prefs, vcs);
  },
);

class VcsNotifier extends StateNotifier<List<String>> {
  static const String prefsKey = 'vcs';
  final SharedPreferences prefs;

  VcsNotifier(this.prefs, super.state);

  Future<String> add(CredentialResponse response) async {
    final credential = response.credential ?? response.transactionId!;
    state = [...state, credential];

    await _save();
    return credential;
  }

  Future<void> remove(String vcJwt) async {
    state = state.where((elem) => elem != vcJwt).toList();
    await _save();
  }

  Future<void> _save() async {
    final toSave = state.map((e) => e).toList();
    await prefs.setStringList('vcs', toSave);
  }

  static List<String> loadSavedVcJwts(SharedPreferences prefs) {
    final saved = prefs.getStringList(prefsKey);

    if (saved == null) {
      return [];
    }

    final vcs = <String>[];
    for (final vcJwt in saved) {
      try {
        vcs.add(vcJwt);
      } on Exception catch (e) {
        throw Exception('Failed to load saved VCs: $e');
      }
    }

    return vcs;
  }
}
