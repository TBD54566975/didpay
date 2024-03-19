import 'package:auto_size_text/auto_size_text.dart';
import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/features/request/request_confirmation_page.dart';
import 'package:didpay/features/request/review_request_page.dart';
import 'package:didpay/shared/fee_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  Widget requestReviewPageTestWidget({List<Override> overrides = const []}) =>
      WidgetHelpers.testableWidget(
        child: const ReviewRequestPage(
          payinAmount: '1.00',
          payinCurrency: 'USD',
          exchangeRate: '17',
          payoutAmount: '17.00',
          payoutCurrency: 'MXN',
          transactionType: TransactionType.deposit,
          serviceFee: '9.0',
          paymentName: 'ABC Bank',
          formData: {'accountNumber': '1234567890'},
        ),
        overrides: overrides,
      );
  group('ReviewRequestPage', () {
    testWidgets('should show input and output amounts', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: requestReviewPageTestWidget()),
      );

      expect(find.widgetWithText(AutoSizeText, '1.00'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
      expect(find.widgetWithText(AutoSizeText, '17.00'), findsOneWidget);
      expect(find.text('MXN'), findsOneWidget);
    });

    testWidgets('should show fee table with service fee and total',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: requestReviewPageTestWidget()),
      );

      expect(find.byType(FeeDetails), findsOneWidget);
      expect(find.text('9.00 MXN'), findsOneWidget);
      expect(find.text('26.00 MXN'), findsOneWidget);
    });

    testWidgets('should show bank name', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: requestReviewPageTestWidget()),
      );

      expect(find.text('ABC Bank'), findsOneWidget);
    });

    testWidgets('should show obscured account number', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: requestReviewPageTestWidget()),
      );

      expect(find.textContaining('•'), findsOneWidget);
      expect(find.textContaining('7890'), findsOneWidget);
      expect(find.textContaining('1234567890'), findsNothing);
    });

    testWidgets('should show request confirmation page on tap of submit button',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: requestReviewPageTestWidget()),
      );

      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(find.byType(RequestConfirmationPage), findsOneWidget);
    });
  });
}
