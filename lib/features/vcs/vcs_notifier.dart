import 'package:didpay/features/kcc/lib.dart';
import 'package:didpay/features/vcs/vcs_service.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final vcsProvider = StateNotifierProvider<VcsNotifier, List<String>>(
  (ref) => throw UnimplementedError(),
);

class VcsNotifier extends StateNotifier<List<String>> {
  static const String storageKey = 'vcs';
  final Box box;
  final VcsService vcsService;

  VcsNotifier._(this.box, this.vcsService, List<String> state) : super(state);

  static Future<VcsNotifier> create(Box box, VcsService vcsService) async {
    final List<String> vcs = await box.get(storageKey) ?? [];

    return VcsNotifier._(box, vcsService, vcs);
  }

  Future<String> addJwt(String vcJwt) async {
    final parsedJwt = vcsService.parseCredential(vcJwt);

    if (state.any((elem) => elem == vcJwt)) {
      return parsedJwt;
    }

    state = [...state, parsedJwt];

    await _save();
    return parsedJwt;
  }

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

  Future<void> reset() async {
    state = [];
    await box.clear();
  }

  Future<void> _save() async {
    await box.put(storageKey, state);
  }
}
