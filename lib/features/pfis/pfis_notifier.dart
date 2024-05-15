import 'package:collection/collection.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web5/web5.dart';

final pfisNotifierProvider = StateNotifierProvider<PfisNotifier, List<Pfi>>(
  (ref) => throw UnimplementedError(),
);

class PfisNotifier extends StateNotifier<List<Pfi>> {
  static const String prefsKey = 'pfis';
  final SharedPreferences prefs;

  PfisNotifier(this.prefs, super.state);

  Future<void> add(String did) async {
    final pfi = state.firstWhereOrNull((pfi) => pfi.did == did);
    if (pfi != null) {
      return;
    }

    try {
      await validatePfi(did);
    } on Exception catch (e) {
      throw Exception('Failed to add PFI: $e');
    }

    final newPfi = Pfi(did: did);
    state = [...state, newPfi];
    await _save();
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
    for (final pfi in saved) {
      try {
        pfis.add(Pfi.fromJson(pfi));
      } on Exception catch (e) {
        throw Exception('Failed to load saved PFI: $e');
      }
    }

    return pfis;
  }

  Future<void> validatePfi(String input) async {
    Did did;
    try {
      did = Did.parse(input);
    } on Exception catch (e) {
      throw Exception('Invalid DID: $e');
    }

    DidResolutionResult resp;
    try {
      resp = await DidResolver.resolve(did.uri);
      if (resp.hasError()) {
        throw Exception(
          'Failed to resolve DID: ${resp.didResolutionMetadata.error}',
        );
      }
    } on Exception catch (e) {
      throw Exception('Failed to resolve PFI DID: $e');
    }

    late DidDocument didDocument;
    if (resp.didDocument == null) {
      throw Exception('Malformed Resolution result: missing DID Document');
    } else {
      didDocument = resp.didDocument!;
    }

    _getServiceEndpoint(didDocument, 'PFI');
    _getServiceEndpoint(didDocument, 'IDV');
  }

  static Uri _getServiceEndpoint(DidDocument didDocument, String serviceType) {
    final service = didDocument.service!.firstWhere(
      (svc) => svc.type == serviceType,
      orElse: () => throw Exception('DID does not have a $serviceType service'),
    );

    if (service.serviceEndpoint.isEmpty) {
      throw Exception(
        'Malformed $serviceType service: missing service endpoint',
      );
    }

    try {
      return Uri.parse(service.serviceEndpoint[0]);
    } on Exception catch (e) {
      throw Exception('PFI has malformed IDV service: $e');
    }
  }
}
