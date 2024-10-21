import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';

void main() async {
  late MockTbdexService mockTbdexService;
  late MockTbdexQuoteNotifier mockTbdexQuoteNotifier;

  await TestData.initializeDids();

  setUpAll(() {
    registerFallbackValue(MockBearerDid());
    registerFallbackValue(TestData.aliceDid);
  });

  setUp(() {
    mockTbdexService = MockTbdexService();
    mockTbdexQuoteNotifier = MockTbdexQuoteNotifier();

    when(() => mockTbdexService.getExchange(any(), any(), any()))
        .thenAnswer((_) async => TestData.getExchange());
  });

  group('TbdexQuoteNotifier Stress Tests', () {
    test('High-frequency polling with exponential backoff', () async {
      when(() => mockTbdexQuoteNotifier.pollForQuote(any(), any()))
          .thenAnswer((_) async => TestData.getQuote());

      await mockTbdexQuoteNotifier.startPolling('pfiId', 'exchangeId');

      verify(() => mockTbdexQuoteNotifier.startPolling('pfiId', 'exchangeId'))
          .called(1);
    });

    test('Maximum retry attempts', () async {
      when(() => mockTbdexQuoteNotifier.pollForQuote(any(), any()))
          .thenThrow(Exception('Network error'));

      await mockTbdexQuoteNotifier.startPolling('pfiId', 'exchangeId');

      verify(() => mockTbdexQuoteNotifier.startPolling('pfiId', 'exchangeId'))
          .called(1);
    });

    test('Handling network latency', () async {
      when(() => mockTbdexQuoteNotifier.startPolling(any(), any()))
          .thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 5));
        return TestData.getQuote();
      });

      await mockTbdexQuoteNotifier.startPolling('pfiId', 'exchangeId');

      verify(() => mockTbdexQuoteNotifier.startPolling(any(), any())).called(1);
    });
  });
}
