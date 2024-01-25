import 'dart:convert';
import 'package:flutter_starter/features/pfis/pfi.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final pfisProvider = FutureProvider<List<Pfi>>((ref) async {
  const url = 'https://raw.githubusercontent.com/TBD54566975/pfi-providers-data/main/pfis.json';
  const cacheKey = 'pfis_cache';

  try {
    // Attempt to fetch data from the URL
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // Parse the JSON data directly into a list of Pfi objects
      List<Pfi> pfis = (json.decode(response.body) as List).map((data) {
        return Pfi(
          id: data['id'] as String,
          name: data['name'] as String,
          didUri: data['didUri'] as String,
        );
      }).toList();

      // Save the data to cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cacheKey, response.body);

      return pfis;
    } else {
      // If server returns an unsuccessful response, try loading from cache
      return await _loadFromCache(cacheKey);
    }
  } catch (e) {
    // In case of an error, try loading from cache
    return await _loadFromCache(cacheKey);
  }
});

Future<List<Pfi>> _loadFromCache(String cacheKey) async {
  final prefs = await SharedPreferences.getInstance();
  String? cachedData = prefs.getString(cacheKey);

  if (cachedData != null) {
    // If cached data is available, parse and return it
    return (json.decode(cachedData) as List).map((data) {
      return Pfi(
        id: data['id'] as String,
        name: data['name'] as String,
        didUri: data['didUri'] as String,
      );
    }).toList();
  } else {
    // If there is no cached data, return an empty list or handle appropriately
    return [];
  }
}
