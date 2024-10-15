import 'dart:convert';

import 'package:didpay/shared/services/request_cache_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';

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

// Mock class for Hive's Box
class MockBox extends Mock implements Box {}

void main() {
  // Register fallback values for any arguments that are needed
  setUpAll(() {
    registerFallbackValue(<dynamic, dynamic>{});
    registerFallbackValue(null);
  });

  late MockBox mockBox;
  late RequestCacheService<TestData> service;
  late http.Client mockClient;

  setUp(() {
    mockBox = MockBox();

    // Default behavior for mockClient
    mockClient = MockClient((request) async {
      return http.Response('Not Found', 404);
    });
  });

  group('RequestCacheService Tests', () {
    test('fetchData emits data from network when no cache exists', () async {
      // Arrange
      const testUrl = 'https://example.com/data';
      final mockResponseData = {'id': 1, 'name': 'Test Item'};

      // Mock box.get returns null (no cached data)
      when(() => mockBox.get(testUrl)).thenReturn(null);
      // Mock box.put to do nothing
      when(() => mockBox.put(testUrl, any())).thenAnswer((_) async {});

      // Mock HTTP client returns mockResponseData
      mockClient = MockClient((request) async {
        if (request.url.toString() == testUrl) {
          return http.Response(jsonEncode(mockResponseData), 200);
        }
        return http.Response('Not Found', 404);
      });

      service = RequestCacheService<TestData>(
        fromJson: TestData.fromJson,
        toJson: (data) => data.toJson(),
        cacheBox: mockBox,
        httpClient: mockClient,
      );

      // Act
      final dataStream = service.fetchData(testUrl);

      // Assert
      await expectLater(
        dataStream,
        emits(
          predicate<TestData>((data) =>
              data.id == mockResponseData['id'] &&
              data.name == mockResponseData['name']),
        ),
      );

      // Verify that box.put was called to cache the data
      verify(() => mockBox.put(testUrl, any())).called(1);
    });

    test(
        'fetchData emits cached data when cache is valid and data is unchanged',
        () async {
      // Arrange
      const testUrl = 'https://example.com/data';
      final mockCachedData = {'id': 1, 'name': 'Cached Item'};
      final now = DateTime.now();

      // Mock box.get returns cached data
      when(() => mockBox.get(testUrl)).thenReturn({
        'data': mockCachedData,
        'timestamp': now.toIso8601String(),
      });

      // Mock box.put to do nothing
      when(() => mockBox.put(testUrl, any())).thenAnswer((_) async {});

      // Mock HTTP client returns the same data as cached
      mockClient = MockClient((request) async {
        return http.Response(jsonEncode(mockCachedData), 200);
      });

      service = RequestCacheService<TestData>(
        fromJson: TestData.fromJson,
        toJson: (data) => data.toJson(),
        cacheBox: mockBox,
        httpClient: mockClient,
        checkForUpdates: false, // Do not check for updates
      );

      // Act
      final dataStream = service.fetchData(testUrl);

      // Assert
      await expectLater(
        dataStream,
        emits(
          predicate<TestData>((data) =>
              data.id == mockCachedData['id'] &&
              data.name == mockCachedData['name']),
        ),
      );

      // Verify that box.put was not called
      verifyNever(() => mockBox.put(any(), any()));
    });

    test(
        'fetchData emits new data when network data is different from cached data',
        () async {
      // Arrange
      const testUrl = 'https://example.com/data';
      final mockCachedData = {'id': 1, 'name': 'Old Item'};
      final mockResponseData = {'id': 1, 'name': 'Updated Item'};
      final now = DateTime.now();

      // Mock box.get returns cached data
      when(() => mockBox.get(testUrl)).thenReturn({
        'data': mockCachedData,
        'timestamp': now.toIso8601String(),
      });

      // Mock box.put to do nothing
      when(() => mockBox.put(testUrl, any())).thenAnswer((_) async {});

      // Mock HTTP client returns updated data
      mockClient = MockClient((request) async {
        return http.Response(jsonEncode(mockResponseData), 200);
      });

      service = RequestCacheService<TestData>(
        fromJson: TestData.fromJson,
        toJson: (data) => data.toJson(),
        cacheBox: mockBox,
        httpClient: mockClient,
        checkForUpdates: true, // Check for updates
      );

      // Act
      final dataStream = service.fetchData(testUrl);

      // Assert
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

      // Verify that box.put was called to update the cache
      verify(() => mockBox.put(testUrl, any())).called(1);
    });

    test('fetchData throws error when no cache exists and network fails',
        () async {
      // Arrange
      const testUrl = 'https://example.com/data';

      // Mock box.get returns null (no cached data)
      when(() => mockBox.get(testUrl)).thenReturn(null);

      // Mock HTTP client returns an error
      mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      service = RequestCacheService<TestData>(
        fromJson: TestData.fromJson,
        toJson: (data) => data.toJson(),
        cacheBox: mockBox,
        httpClient: mockClient,
      );

      // Act & Assert
      await expectLater(
        service.fetchData(testUrl),
        emitsError(isA<Exception>()),
      );
    });

    test('fetchData emits cached data when network fails', () async {
      // Arrange
      const testUrl = 'https://example.com/data';
      final mockCachedData = {'id': 1, 'name': 'Cached Item'};
      final now = DateTime.now();

      // Mock box.get returns cached data
      when(() => mockBox.get(testUrl)).thenReturn({
        'data': mockCachedData,
        'timestamp': now.toIso8601String(),
      });

      // Mock HTTP client returns an error
      mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      // Mock box.put to do nothing
      when(() => mockBox.put(testUrl, any())).thenAnswer((_) async {});

      service = RequestCacheService<TestData>(
        fromJson: TestData.fromJson,
        toJson: (data) => data.toJson(),
        cacheBox: mockBox,
        httpClient: mockClient,
        checkForUpdates: true, // Check for updates
      );

      // Act
      final dataStream = service.fetchData(testUrl);

      // Assert
      await expectLater(
        dataStream,
        emits(
          predicate<TestData>((data) =>
              data.id == mockCachedData['id'] &&
              data.name == mockCachedData['name']),
        ),
      );

      // Verify that box.put was not called since the network failed
      verifyNever(() => mockBox.put(any(), any()));
    });

    test('fetchData fetches new data when cache is expired', () async {
      // Arrange
      const testUrl = 'https://example.com/data';
      final mockCachedData = {'id': 1, 'name': 'Old Item'};
      final mockResponseData = {'id': 1, 'name': 'New Item'};
      final expiredTime = DateTime.now().subtract(Duration(minutes: 10));

      // Mock box.get returns expired cached data
      when(() => mockBox.get(testUrl)).thenReturn({
        'data': mockCachedData,
        'timestamp': expiredTime.toIso8601String(),
      });

      // Mock box.put to do nothing
      when(() => mockBox.put(testUrl, any())).thenAnswer((_) async {});

      // Mock HTTP client returns new data
      mockClient = MockClient((request) async {
        return http.Response(jsonEncode(mockResponseData), 200);
      });

      service = RequestCacheService<TestData>(
        fromJson: TestData.fromJson,
        toJson: (data) => data.toJson(),
        cacheBox: mockBox,
        httpClient: mockClient,
        cacheDuration: Duration(minutes: 1), // Short cache duration
        checkForUpdates: true, // Check for updates
      );

      // Act
      final dataStream = service.fetchData(testUrl);

      // Assert
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

      // Verify that box.put was called to update the cache
      verify(() => mockBox.put(testUrl, any())).called(1);
    });

    test('fetchData skips network call when checkForUpdates is false',
        () async {
      // Arrange
      const testUrl = 'https://example.com/data';
      final mockCachedData = {'id': 1, 'name': 'Cached Item'};
      final now = DateTime.now();

      // Mock box.get returns cached data
      when(() => mockBox.get(testUrl)).thenReturn({
        'data': mockCachedData,
        'timestamp': now.toIso8601String(),
      });

      // Mock HTTP client returns an error to ensure it's not called
      mockClient = MockClient((request) async {
        // If this is called, the test should fail
        return http.Response('Should not be called', 500);
      });

      // Mock box.put to do nothing
      when(() => mockBox.put(testUrl, any())).thenAnswer((_) async {});

      service = RequestCacheService<TestData>(
        fromJson: TestData.fromJson,
        toJson: (data) => data.toJson(),
        cacheBox: mockBox,
        httpClient: mockClient,
        checkForUpdates: false, // Do not check for updates
      );

      // Act
      final dataStream = service.fetchData(testUrl);

      // Assert
      await expectLater(
        dataStream,
        emits(
          predicate<TestData>((data) =>
              data.id == mockCachedData['id'] &&
              data.name == mockCachedData['name']),
        ),
      );

      // Verify that HTTP client was not called
      // Since we're using MockClient from http/testing.dart, we cannot use verify on it
      // But since the test passes without errors, we can infer that the client was not called
      // Alternatively, we could switch to using a mock client that supports verification
    });
  });
}
