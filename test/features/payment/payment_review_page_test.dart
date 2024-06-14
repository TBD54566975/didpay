import 'package:auto_size_text/auto_size_text.dart';
import 'package:decimal/decimal.dart';
import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/payment/payment_fee_details.dart';
import 'package:didpay/features/payment/payment_review_page.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/pfis/pfi.dart';
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

  Widget reviewPaymentPageTestWidget() => WidgetHelpers.testableWidget(
        child: PaymentReviewPage(
          paymentState: PaymentState(
            selectedPfi: const Pfi(did: ''),
            payoutAmount: Decimal.parse('17.00'),
            payinCurrency: 'USD',
            payoutCurrency: 'MXN',
            exchangeRate: Decimal.parse('17.00'),
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

  group('PaymentReviewPage', () {
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
