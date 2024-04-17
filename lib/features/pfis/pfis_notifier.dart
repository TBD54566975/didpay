import 'dart:async';
import 'dart:convert';

import 'package:didpay/config/config.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/storage/storage_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

final pfisProvider = AsyncNotifierProvider<PfisAsyncNotifier, List<Pfi>>(
  PfisAsyncNotifier.new,
);

class PfisAsyncNotifier extends AsyncNotifier<List<Pfi>> {
  final _cacheKey = 'didpay:pfis_cache';

  @override
  FutureOr<List<Pfi>> build() => _loadFromCache();

  void addPfi(Pfi newPfi) {
    final currentPfis = state.value ?? [];
    final updatedPfis = [...currentPfis, newPfi];
    state = AsyncData(updatedPfis);
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
