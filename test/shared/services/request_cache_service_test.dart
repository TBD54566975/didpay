import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:didpay/shared/services/request_cache_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class TestData {
  final int id;
  final String name;

  TestData({required this.id, required this.name});

  factory TestData.fromJson(Map<String, dynamic> json) {
    return TestData(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

void main() {
  // Initialize in-memory Hive storage before tests
  setUp(() async {
    await setUpTestHive();
  });

  // Clean up after tests
  tearDown(() async {
    await tearDownTestHive();
  });

  group('RequestCacheService Tests', () {
    test('fetchData emits data from network when no cache exists', () async {
      // Arrange
      const testUrl = 'https://example.com/data';
      final mockResponseData = {'id': 1, 'name': 'Test Item'};
      final mockClient = MockClient((request) async {
        if (request.url.toString() == testUrl) {
          return http.Response(jsonEncode(mockResponseData), 200);
        }
        return http.Response('Not Found', 404);
      });

      final service = RequestCacheService<TestData>(
        fromJson: TestData.fromJson,
        toJson: (data) => data.toJson(),
        httpClient: mockClient,
      );

      final dataStream = service.fetchData(testUrl);

      await expectLater(
        dataStream,
        emits(predicate<TestData>((data) =>
            data.id == mockResponseData['id'] &&
            data.name == mockResponseData['name'])),
      );
    });

    test(
        'fetchData emits cached data when cache is valid and data is unchanged',
        () async {
      // Arrange
      const testUrl = 'https://example.com/data';
      final mockCachedData = {'id': 1, 'name': 'Cached Item'};
      final now = DateTime.now();

      // Pre-populate the Hive box with cached data
      final box = await Hive.openBox('network_cache');
      final cacheKey = testUrl.hashCode.toString();
      await box.put(cacheKey, {
        'data': mockCachedData,
        'timestamp': now.toIso8601String(),
      });

      // Mock HTTP client returns the same data as cached
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(mockCachedData), 200);
      });

      final service = RequestCacheService<TestData>(
        fromJson: TestData.fromJson,
        toJson: (data) => data.toJson(),
        httpClient: mockClient,
      );

      final dataStream = service.fetchData(testUrl);

      await expectLater(
        dataStream,
        emits(predicate<TestData>((data) =>
            data.id == mockCachedData['id'] &&
            data.name == mockCachedData['name'])),
      );
    });

    test(
        'fetchData emits new data when network data is different from cached data',
        () async {
      // Arrange
      const testUrl = 'https://example.com/data';
      final mockCachedData = {'id': 1, 'name': 'Old Item'};
      final mockResponseData = {'id': 1, 'name': 'Updated Item'};
      final now = DateTime.now();

      // Pre-populate the Hive box with old cached data
      final box = await Hive.openBox('network_cache');
      final cacheKey = testUrl.hashCode.toString();
      await box.put(cacheKey, {
        'data': mockCachedData,
        'timestamp': now.toIso8601String(),
      });

      // Mock HTTP client returns updated data
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(mockResponseData), 200);
      });

      final service = RequestCacheService<TestData>(
        fromJson: TestData.fromJson,
        toJson: (data) => data.toJson(),
        httpClient: mockClient,
      );

      final dataStream = service.fetchData(testUrl);

      await expectLater(
        dataStream,
        emitsInOrder([
          predicate<TestData>((data) =>
              data.id == mockCachedData['id'] &&
              data.name == mockCachedData['name']),
          predicate<TestData>((data) =>
              data.id == mockResponseData['id'] &&
              data.name == mockResponseData['name']),
        ]),
      );
    });

    test('fetchData throws error when no cache exists and network fails',
        () async {
      // Arrange
      const testUrl = 'https://example.com/data';

      // Mock HTTP client returns an error
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final service = RequestCacheService<TestData>(
        fromJson: TestData.fromJson,
        toJson: (data) => data.toJson(),
        httpClient: mockClient,
      );

      expect(
        service.fetchData(testUrl),
        emitsError(isA<Exception>()),
      );
    });

    test('fetchData emits cached data when network fails', () async {
      // Arrange
      const testUrl = 'https://example.com/data';
      final mockCachedData = {'id': 1, 'name': 'Cached Item'};
      final now = DateTime.now();

      // Pre-populate the Hive box with cached data
      final box = await Hive.openBox('network_cache');
      final cacheKey = testUrl.hashCode.toString();
      await box.put(cacheKey, {
        'data': mockCachedData,
        'timestamp': now.toIso8601String(),
      });

      // Mock HTTP client returns an error
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final service = RequestCacheService<TestData>(
        fromJson: TestData.fromJson,
        toJson: (data) => data.toJson(),
        httpClient: mockClient,
      );

      final dataStream = service.fetchData(testUrl);

      await expectLater(
        dataStream,
        emits(predicate<TestData>((data) =>
            data.id == mockCachedData['id'] &&
            data.name == mockCachedData['name'])),
      );
    });

    test('fetchData fetches new data when cache is expired', () async {
      // Arrange
      const testUrl = 'https://example.com/data';
      final mockCachedData = {'id': 1, 'name': 'Old Item'};
      final mockResponseData = {'id': 1, 'name': 'New Item'};
      final expiredTime = DateTime.now().subtract(Duration(minutes: 10));

      // Pre-populate the Hive box with expired cached data
      final box = await Hive.openBox('network_cache');
      final cacheKey = testUrl.hashCode.toString();
      await box.put(cacheKey, {
        'data': mockCachedData,
        'timestamp': expiredTime.toIso8601String(),
      });

      // Mock HTTP client returns new data
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(mockResponseData), 200);
      });

      final service = RequestCacheService<TestData>(
        fromJson: TestData.fromJson,
        toJson: (data) => data.toJson(),
        httpClient: mockClient,
        cacheDuration: Duration(minutes: 1), // Set cache duration for the test
      );

      final dataStream = service.fetchData(testUrl);

      await expectLater(
        dataStream,
        emitsInOrder([
          predicate<TestData>((data) =>
              data.id == mockCachedData['id'] &&
              data.name == mockCachedData['name']),
          predicate<TestData>((data) =>
              data.id == mockResponseData['id'] &&
              data.name == mockResponseData['name']),
        ]),
      );
    });
  });
}
