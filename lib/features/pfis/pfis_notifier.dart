import 'dart:async';
import 'dart:convert';

import 'package:didpay/config/config.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/storage/storage_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:web5/web5.dart';

final pfisProvider = AsyncNotifierProvider<PfisAsyncNotifier, List<Pfi>>(
  PfisAsyncNotifier.new,
);

class PfisAsyncNotifier extends AsyncNotifier<List<Pfi>> {
  final _cacheKey = 'didpay:pfis_cache';

  @override
  FutureOr<List<Pfi>> build() => _loadFromCache();

  Future<NuPfi> addPfi(String input) async {
    Did did;
    try {
      did = Did.parse(input);
    } on Exception catch (e) {
      throw Exception('Invalid DID: $e');
    }

    DidResolutionResult resp;
    try {
      resp = await DidResolver.resolve(input);
      if (resp.hasError()) {
        throw Exception(
          'Failed to resolve DID: ${resp.didResolutionMetadata.error}',
        );
      }
    } on Exception catch (e) {
      throw Exception('Failed to resolve PFI DID: $e');
    }

    return NuPfi(
      did: did,
      didDocument: resp.didDocument!,
      idvServiceEndpoint: _getServiceEndpoint(resp.didDocument!, 'IDV'),
      tbdexServiceEndpoint: _getServiceEndpoint(resp.didDocument!, 'KYC'),
    );
  }

  Uri _getServiceEndpoint(DidDocument didDocument, String serviceType) {
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

  Future<void> reload() async {
    if (Config.devPfis.isNotEmpty) {
      state = AsyncData(Config.devPfis);
      return;
    }

    final pfis = await _loadFromCache();
    // Show loading indicator if cache is empty
    state = pfis.isEmpty ? const AsyncLoading() : AsyncData(pfis);

    final response = await http.get(Uri.parse(Config.pfisJsonUrl));
    if (response.statusCode != 200) {
      state = AsyncError('Failed to load PFIs', StackTrace.current);
      return;
    }

    await ref
        .read(sharedPreferencesProvider)
        .setString(_cacheKey, response.body);

    state = AsyncData(
      List<Pfi>.from(
        (json.decode(response.body) as List)
            .map((item) => Pfi.fromJson(item as Map<String, dynamic>)),
      ),
    );
  }

  Future<List<Pfi>> _loadFromCache() async {
    final cachedData = ref.read(sharedPreferencesProvider).getString(_cacheKey);
    if (cachedData == null) {
      return [];
    }

    return List<Pfi>.from(
      (json.decode(cachedData) as List).map(
        (item) => Pfi.fromJson(item as Map<String, dynamic>),
      ),
    );
  }
}
