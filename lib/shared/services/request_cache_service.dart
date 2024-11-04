import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class RequestCacheService<T> {
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;
  final Duration cacheDuration;
  final String networkCacheKey;
  final http.Client httpClient;
  final bool checkForUpdates;
  final Box cacheBox;

  RequestCacheService({
    required this.fromJson,
    required this.toJson,
    required this.cacheBox,
    this.cacheDuration = const Duration(minutes: 1),
    this.networkCacheKey = 'network_cache',
    http.Client? httpClient,
    this.checkForUpdates = false,
  }) : httpClient = httpClient ?? http.Client();

  /// Fetches data from the cache and API.
  Stream<T> fetchData(String url) async* {
    final cacheKey = url;
    bool cacheEmitted = false;

    try {
      // Check for cached data
      final cachedEntry = await cacheBox.get(cacheKey);
      if (cachedEntry != null && cachedEntry is Map) {
        final cachedMap = Map<String, dynamic>.from(cachedEntry);
        final cachedTimestamp =
            DateTime.parse(cachedMap['timestamp'] as String);
        final cachedDataJson =
            Map<String, dynamic>.from(cachedMap['data'] ?? {});
        final cachedData = fromJson(cachedDataJson);
        // Emit cached data
        yield cachedData;
        cacheEmitted = true;

        final now = DateTime.now();
        // Decide whether to fetch new data based on cache validity
        if (now.difference(cachedTimestamp) < cacheDuration &&
            !checkForUpdates) {
          // Cache is still valid, but we'll fetch new data to check for updates
          return;
        }
      }

      // Fetch data from the network
      try {
        final response = await httpClient.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final dataMap = jsonDecode(response.body) as Map<String, dynamic>;
          final data = fromJson(dataMap);

          // Compare with cached data
          bool isDataUpdated = true;
          if (cachedEntry != null && cachedEntry is Map) {
            final cachedDataJson =
                Map<String, dynamic>.from(cachedEntry['data'] ?? {});
            // Use DeepCollectionEquality for deep comparison
            const equalityChecker = DeepCollectionEquality();
            if (equalityChecker.equals(cachedDataJson, dataMap)) {
              isDataUpdated = false;
            }
          }

          // Cache the new data with a timestamp
          final cacheEntry = {
            'data': toJson(data),
            'timestamp': DateTime.now().toIso8601String(),
          };
          await cacheBox.put(cacheKey, cacheEntry);

          if (isDataUpdated) {
            yield data;
          }
        } else {
          throw Exception(
            'Failed to load data from $url. Status code: ${response.statusCode}',
          );
        }
      } catch (e) {
        if (!cacheEmitted) {
          // No cached data was emitted before, so we need to throw an error
          throw Exception('Error fetching data from $url: $e');
        }
        // Else, we have already emitted cached data, so we can silently fail or log the error
      }
    } catch (e) {
      if (!cacheEmitted) {
        // No cached data was emitted before, so we need to throw an error
        throw Exception('Error fetching data from $url: $e');
      }
      // Else, we have already emitted cached data, so we can silently fail or log the error
      log('Error fetching data from $url: $e');
    }
  }
}
