import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/account/account_providers.dart';
import 'package:didpay/features/countries/country.dart';
import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/features/payment/payment_confirmation_page.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/payment/review_payment_page.dart';
import 'package:didpay/features/tbdex/quote_notifier.dart';
import 'package:didpay/features/tbdex/tbdex_providers.dart';
import 'package:didpay/shared/fee_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tbdex/tbdex.dart';
import 'package:web5/web5.dart';

import '../../helpers/widget_helpers.dart';

void main() async {
  final did = await DidDht.create();

  Widget reviewPaymentPageTestWidget({List<Override> overrides = const []}) =>
      WidgetHelpers.testableWidget(
        child: const ReviewPaymentPage(
          exchangeId: '',
          paymentState: PaymentState(
            payoutAmount: '17.00',
            payinCurrency: 'USD',
            payoutCurrency: 'MXN',
            exchangeRate: '17',
            transactionType: TransactionType.deposit,
            paymentName: 'ABC Bank',
            formData: {'accountNumber': '1234567890'},
          ),
        ),
        overrides: [
          quoteProvider.overrideWith(_MockQuoteNotifier.new),
          didProvider.overrideWithValue(did),
          countryProvider.overrideWith(
            (ref) => const Country(name: 'Mexico', code: 'MX'),
          ),
        ],
      );
  group('ReviewPaymentPage', () {
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

      expect(find.byType(FeeDetails), findsOneWidget);
      expect(find.text('0.5 MXN'), findsOneWidget);
    });

    testWidgets('should show bank name', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: reviewPaymentPageTestWidget()),
      );
      await tester.pumpAndSettle();

      expect(find.text('ABC Bank'), findsOneWidget);
    });

    testWidgets('should show payment confirmation page on tap of submit button',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: reviewPaymentPageTestWidget()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pay 10.11 USD'));
      await tester.pumpAndSettle();

      expect(find.byType(PaymentConfirmationPage), findsOneWidget);
    });
  });
}

class _MockQuoteNotifier extends QuoteAsyncNotifier {
  _MockQuoteNotifier() : super();

  @override
  FutureOr<Quote?> build() {
    const quoteString =
        '{"data":{"payin":{"fee":"0.1","amount":"10","currencyCode":"USD"},"payout":{"fee":"0.5","amount":"500","currencyCode":"MXN"},"expiresAt":"2024-05-03T22:26:39Z"},"metadata":{"id":"quote_01hwxpncmpfkmt16azhe9vhxvr","to":"did:jwk:eyJrdHkiOiJPS1AiLCJjcnYiOiJFZDI1NTE5IiwieCI6Ik5qUUNMeE9tVEN4NFlYQ1MyR2t0T2FQbkZHLXBUZFRqZ0F0U3AtX002SEEifQ","from":"did:jwk:eyJrdHkiOiJPS1AiLCJjcnYiOiJFZDI1NTE5IiwieCI6ImswMEpaTXFVdGRtUFZORkVhOHIxek1FWXZ3WXFCVnVVcWtLS3BsdkxhSEkifQ","kind":"quote","protocol":"1.0","createdAt":"2024-05-02T22:26:39Z","exchangeId":"rfq_01hwxpmsrje6cts27kdzy3n66y"},"signature":"eyJhbGciOiJFZERTQSIsImtpZCI6ImRpZDpqd2s6ZXlKcmRIa2lPaUpQUzFBaUxDSmpjbllpT2lKRlpESTFOVEU1SWl3aWVDSTZJbXN3TUVwYVRYRlZkR1J0VUZaT1JrVmhPSEl4ZWsxRldYWjNXWEZDVm5WVmNXdExTM0JzZGt4aFNFa2lmUSMwIn0..KRs_rAGNTZ_w9H-8lg3RR4jShi4iPTz4sW9o7eCmaMKPH4ETYbK4n0xRskKzyS-Wkx3oqGY0vFQs5kYsysi_Aw"}';
    final quoteJson = jsonDecode(quoteString);
    final quote = Quote.fromJson(quoteJson);
    return quote;
  }

  @override
  void startPolling(String exchangeId) {}
}
