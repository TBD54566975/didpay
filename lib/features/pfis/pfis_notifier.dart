import 'dart:async';
import 'dart:convert';

import 'package:didpay/config/config.dart';
import 'package:http/http.dart' as http;
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/services/service_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final pfisProvider = AsyncNotifierProvider<PfisAsyncNotifier, List<Pfi>>(
  () => PfisAsyncNotifier(),
);

class PfisAsyncNotifier extends AsyncNotifier<List<Pfi>> {
  final _cacheKey = 'didpay:pfis_cache';

  @override
  FutureOr<List<Pfi>> build() => _loadFromCache();

  Future<void> reload() async {
    if (Config.devPfis.isNotEmpty) {
      state = const AsyncData(Config.devPfis);
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

    ref.read(sharedPreferencesProvider).setString(_cacheKey, response.body);

    state = AsyncData((json.decode(response.body) as List)
        .map((p) => Pfi.fromJson(p))
        .toList());
  }

  Future<List<Pfi>> _loadFromCache() async {
    final cachedData = ref.read(sharedPreferencesProvider).getString(_cacheKey);
    if (cachedData == null) {
      return [];
    }

    return (json.decode(cachedData) as List)
        .map((p) => Pfi.fromJson(p))
        .toList();
  }
}
