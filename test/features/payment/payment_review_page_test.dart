import 'package:auto_size_text/auto_size_text.dart';
import 'package:decimal/decimal.dart';
import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/payment/payment_fee_details.dart';
import 'package:didpay/features/payment/payment_review_page.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/tbdex/tbdex_quote_notifier.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';
import '../../helpers/widget_helpers.dart';

void main() async {
  await TestData.initializeDids();

  final did = TestData.aliceDid;
  final quote = TestData.getQuote();
  final order = TestData.getOrder();

  late MockTbdexService mockTbdexService;
  late MockTbdexQuoteNotifier mockTbdexQuoteNotifier;

  setUp(() {
    mockTbdexService = MockTbdexService();
    mockTbdexQuoteNotifier = MockTbdexQuoteNotifier();

    when(
      () => mockTbdexService.submitOrder(any(), any(), any()),
    ).thenAnswer((_) async => order);

    when(
      () => mockTbdexService.getExchange(any(), any(), any()),
    ).thenAnswer((_) async => TestData.getExchange());

    when(
      () => mockTbdexQuoteNotifier.startPolling(const Pfi(did: '123'), '123'),
    ).thenAnswer((_) async => quote);
  });

  group('PaymentReviewPage', () {
    Widget reviewPaymentPageTestWidget() => WidgetHelpers.testableWidget(
          child: PaymentReviewPage(
            paymentState: PaymentState(
              selectedPfi: const Pfi(did: '123'),
              payinAmount: Decimal.parse('100.00'),
              payoutAmount: Decimal.parse('0.12'),
              payinCurrency: 'AUD',
              payoutCurrency: 'BTC',
              exchangeRate: Decimal.parse('17.00'),
              exchangeId: '123',
              transactionType: TransactionType.deposit,
              paymentName: 'ABC Bank',
              formData: {'accountNumber': '1234567890'},
            ),
          ),
          overrides: [
            didProvider.overrideWithValue(did),
            quoteProvider.overrideWith(() => mockTbdexQuoteNotifier),
            tbdexServiceProvider.overrideWith((ref) => mockTbdexService),
          ],
        );

    setUpAll(() {
      registerFallbackValue(did);
      registerFallbackValue(const Pfi(did: '123'));
    });

    testWidgets('should show input and output amounts', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: reviewPaymentPageTestWidget()),
      );

      await tester.pumpAndSettle();

      expect(find.widgetWithText(AutoSizeText, '100'), findsOneWidget);
      expect(find.text('AUD'), findsOneWidget);
      expect(find.widgetWithText(AutoSizeText, '0.12'), findsOneWidget);
      expect(find.text('BTC'), findsOneWidget);
    });

    testWidgets('should show fee details', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: reviewPaymentPageTestWidget()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PaymentFeeDetails), findsOneWidget);
      expect(find.text('0.01 AUD'), findsOneWidget);
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

      await tester.tap(find.text('Pay 100 AUD'));
      await tester.pumpAndSettle();

      expect(find.text('Order confirmed!'), findsOneWidget);
    });
  });
}
