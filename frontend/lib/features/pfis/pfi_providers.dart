import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_starter/features/pfis/pfi.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final pfisProvider = FutureProvider<List<Pfi>>((ref) async {
  const url = 'https://raw.githubusercontent.com/TBD54566975/pfi-providers-data/main/pfis.json';
  const cacheKey = 'pfi_cache';


  // fall back to a dev PFI if passed on command line like: flutter run --dart-define=DEV_PFI=your_did_string
  const devPfi = String.fromEnvironment('DEV_PFI');
  if (devPfi != '' && devPfi != null) {
    return [
      Pfi(
        id: 'dev',
        name: 'Dev PFI',
        didUri: devPfi,
      ),
    ];
  }

  // First, try loading from cache
  List<Pfi> pfis = await _loadFromCache(cacheKey);
  if (pfis.isNotEmpty) {
    // If cache has data, return it first
    // Then, asynchronously refresh the cache
    _refreshCache(url, cacheKey);
    return pfis;
  } else {
    // If cache is empty, fetch from the URL
    return await _fetchFromURL(url, cacheKey);
  }
});

Future<List<Pfi>> _loadFromCache(String cacheKey) async {
  final prefs = await SharedPreferences.getInstance();
  String? cachedData = prefs.getString(cacheKey);

  if (cachedData != null) {
    return (json.decode(cachedData) as List).map((data) {
      return Pfi(
        id: data['id'] as String,
        name: data['name'] as String,
        didUri: data['didUri'] as String,
      );
    }).toList();
  } else {
    return [];
  }
}

Future<List<Pfi>> _fetchFromURL(String url, String cacheKey) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cacheKey, response.body);

      return (json.decode(response.body) as List).map((data) {
        return Pfi(
          id: data['id'] as String,
          name: data['name'] as String,
          didUri: data['didUri'] as String,
        );
      }).toList();
    }
  } catch (e) {
    // Handle the error or return an empty list
    debugPrint(e.toString());
  }
  return [];
}

Future<void> _refreshCache(String url, String cacheKey) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cacheKey, response.body);
    }
  } catch (e) {
    // Handle the error silently as this is a background refresh
    debugPrint(e.toString());
  }
}
