import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/payin/payin.dart';
import 'package:didpay/features/payment/payment_amount_page.dart';
import 'package:didpay/features/payment/payment_fee_details.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/payout/payout.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
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
  final offerings = TestData.getOfferingsMap();
  final pfis = TestData.getPfis();

  late MockTbdexService mockTbdexService;
  late MockPfisNotifier mockPfisNotifier;

  setUp(() {
    mockTbdexService = MockTbdexService();
    mockPfisNotifier = MockPfisNotifier(pfis);

    when(
      () => mockTbdexService.getOfferings(
        pfis,
        payoutCurrency: 'USDC',
      ),
    ).thenAnswer((_) async => offerings);
  });

  setUpAll(() {
    registerFallbackValue(
      const PaymentState(transactionType: TransactionType.deposit),
    );
  });

  group('PaymentAmountPage', () {
    Widget paymentAmountPageTestWidget() => WidgetHelpers.testableWidget(
          child: const PaymentAmountPage(
            paymentState:
                PaymentState(transactionType: TransactionType.deposit),
          ),
          overrides: [
            didProvider.overrideWith((ref) => did),
            tbdexServiceProvider.overrideWith((ref) => mockTbdexService),
            pfisProvider.overrideWith((ref) => mockPfisNotifier),
          ],
        );

    testWidgets('should show payin and payout', (tester) async {
      await tester.pumpWidget(paymentAmountPageTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Payin), findsOneWidget);
      expect(find.byType(Payout), findsOneWidget);
    });

    testWidgets('should show fee details', (tester) async {
      await tester.pumpWidget(paymentAmountPageTestWidget());
      await tester.pumpAndSettle(Durations.extralong1);

      expect(find.byType(PaymentFeeDetails), findsOneWidget);
    });

    testWidgets('should show next button', (tester) async {
      await tester.pumpWidget(paymentAmountPageTestWidget());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(FilledButton, 'Next'), findsOneWidget);
    });

    testWidgets('should change deposit input amount after number pad press',
        (tester) async {
      await tester.pumpWidget(paymentAmountPageTestWidget());
      await tester.pumpAndSettle();

      for (var i = 1; i <= 9; i++) {
        await tester.tap(find.text('$i'));
        await tester.pumpAndSettle();

        expect(find.text('$i'), findsAtLeast(1));

        await tester.tap(find.text('<'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets(
        'should show the currency list on tap of the currency converter dropdown toggle',
        (tester) async {
      await tester.pumpWidget(paymentAmountPageTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
