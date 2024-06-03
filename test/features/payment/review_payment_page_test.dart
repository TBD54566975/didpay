import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/payment/payment_fee_details.dart';
import 'package:didpay/features/payment/payment_review_page.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbdex/tbdex.dart';
import 'package:web5/web5.dart';

import '../../helpers/mocks.dart';
import '../../helpers/widget_helpers.dart';

void main() async {
  const quoteString =
      '{"data":{"payin":{"fee":"0.1","amount":"10","currencyCode":"USD"},"payout":{"fee":"0.5","amount":"500","currencyCode":"MXN"},"expiresAt":"2024-05-03T22:26:39Z"},"metadata":{"id":"quote_01hwxpncmpfkmt16azhe9vhxvr","to":"did:jwk:eyJrdHkiOiJPS1AiLCJjcnYiOiJFZDI1NTE5IiwieCI6Ik5qUUNMeE9tVEN4NFlYQ1MyR2t0T2FQbkZHLXBUZFRqZ0F0U3AtX002SEEifQ","from":"did:jwk:eyJrdHkiOiJPS1AiLCJjcnYiOiJFZDI1NTE5IiwieCI6ImswMEpaTXFVdGRtUFZORkVhOHIxek1FWXZ3WXFCVnVVcWtLS3BsdkxhSEkifQ","kind":"quote","protocol":"1.0","createdAt":"2024-05-02T22:26:39Z","exchangeId":"rfq_01hwxpmsrje6cts27kdzy3n66y"},"signature":"eyJhbGciOiJFZERTQSIsImtpZCI6ImRpZDpqd2s6ZXlKcmRIa2lPaUpQUzFBaUxDSmpjbllpT2lKRlpESTFOVEU1SWl3aWVDSTZJbXN3TUVwYVRYRlZkR1J0VUZaT1JrVmhPSEl4ZWsxRldYWjNXWEZDVm5WVmNXdExTM0JzZGt4aFNFa2lmUSMwIn0..KRs_rAGNTZ_w9H-8lg3RR4jShi4iPTz4sW9o7eCmaMKPH4ETYbK4n0xRskKzyS-Wkx3oqGY0vFQs5kYsysi_Aw"}';
  const orderString =
      '''{"metadata":{"kind":"order","to":"did:jwk:eyJrdHkiOiJPS1AiLCJhbGciOiJFZERTQSIsImtpZCI6ImpCU21VNF94OGZYSkZ4QkNyUWN3QlJ1VTZ4WG9sSG1STjF0bkFLSWFzWDgiLCJjcnYiOiJFZDI1NTE5IiwieCI6ImJBdHk5dWwyU1ZvUlRQUm51aVlVdHVtN2x0WHE4c2VCWFJBQ3o4SjRoZGMifQ","from":"did:jwk:eyJrdHkiOiJPS1AiLCJhbGciOiJFZERTQSIsImtpZCI6InFCY1o3blNCZnIxdjRObnd1bjJGbEFuQm9RdjdQeDJPODE4NTNwMU9EdG8iLCJjcnYiOiJFZDI1NTE5IiwieCI6ImtGWnkzUE9hRmhCRjFTbERubUlYSjFCYUxtVGpOeXJQWDB0bXRXMVppNUEifQ","id":"order_01hy4b39mcewxvzckyf6x96ykp","exchangeId":"rfq_01hy4b39m8f21s1q8y1kwa7ec6","createdAt":"2024-05-17T22:34:54.988029Z","protocol":"1.0"},"data":{},"signature":"eyJhbGciOiJFZERTQSIsImtpZCI6ImRpZDpqd2s6ZXlKcmRIa2lPaUpQUzFBaUxDSmhiR2NpT2lKRlpFUlRRU0lzSW10cFpDSTZJbkZDWTFvM2JsTkNabkl4ZGpST2JuZDFiakpHYkVGdVFtOVJkamRRZURKUE9ERTROVE53TVU5RWRHOGlMQ0pqY25ZaU9pSkZaREkxTlRFNUlpd2llQ0k2SW10R1dua3pVRTloUm1oQ1JqRlRiRVJ1YlVsWVNqRkNZVXh0VkdwT2VYSlFXREIwYlhSWE1WcHBOVUVpZlEjMCJ9..nbp76ytzYAvvG9bizY5ez2TGv7SazA6vZFV_9vPGq1M-_vi2Bs7FP4DumWJOtgJBZ_vMJGxZWwW8oXVYN31ECA"}''';

  final quoteJson = jsonDecode(quoteString);
  final orderJson = jsonDecode(orderString);

  final quote = Quote.fromJson(quoteJson);
  final order = Order.fromJson(orderJson);

  final did = await DidDht.create();

  late MockTbdexService mockTbdexService;

  Widget reviewPaymentPageTestWidget({List<Override> overrides = const []}) =>
      WidgetHelpers.testableWidget(
        child: const PaymentReviewPage(
          paymentState: PaymentState(
            selectedPfi: Pfi(did: ''),
            payoutAmount: '17.00',
            payinCurrency: 'USD',
            payoutCurrency: 'MXN',
            exchangeRate: '17',
            exchangeId: '',
            transactionType: TransactionType.deposit,
            paymentName: 'ABC Bank',
            formData: {'accountNumber': '1234567890'},
          ),
        ),
        overrides: [
          didProvider.overrideWithValue(did),
          tbdexServiceProvider.overrideWith((ref) => mockTbdexService),
        ],
      );
  group('ReviewPaymentPage', () {
    setUp(() {
      mockTbdexService = MockTbdexService();

      when(
        () => mockTbdexService.submitOrder(any(), any(), any()),
      ).thenAnswer((_) async => order);

      when(
        () => mockTbdexService.pollForQuote(any(), any(), any()),
      ).thenAnswer((_) async => quote);
    });

    setUpAll(() {
      registerFallbackValue(did);
      registerFallbackValue(const Pfi(did: 'did:web:x%3A8892:ingress'));
    });

    testWidgets('should show input and output amounts', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: reviewPaymentPageTestWidget()),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AutoSizeText, '10'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
      expect(find.widgetWithText(AutoSizeText, '500'), findsOneWidget);
      expect(find.text('MXN'), findsOneWidget);
    });

    testWidgets('should show fee details', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: reviewPaymentPageTestWidget()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PaymentFeeDetails), findsOneWidget);
      expect(find.text('0.5 MXN'), findsOneWidget);
    });

    testWidgets('should show bank name', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: reviewPaymentPageTestWidget()),
      );
      await tester.pumpAndSettle();

      expect(find.text('ABC Bank'), findsOneWidget);
    });

    testWidgets('should show order confirmation on tap of submit button',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: reviewPaymentPageTestWidget()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pay 10 USD'));
      await tester.pumpAndSettle();

      expect(find.text('Order confirmed!'), findsOneWidget);
    });
  });
}
