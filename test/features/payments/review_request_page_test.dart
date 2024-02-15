import 'package:didpay/features/payments/review_request_page.dart';
import 'package:didpay/shared/fee_details.dart';
import 'package:didpay/shared/success_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  group('ReviewRequestPage', () {
    const mockReviewRequestPage = ReviewRequestPage(
      inputAmount: '1.00',
      inputCurrency: 'USD',
      exchangeRate: '17',
      outputAmount: '17.00',
      outputCurrency: 'MXN',
      transactionType: 'Deposit',
      serviceFee: '9.0',
      bankName: 'ABC Bank',
      formData: {'accountNumber': '1234567890'},
    );

    testWidgets('should show input and output amounts', (tester) async {
      await tester.pumpWidget(
          WidgetHelpers.testableWidget(child: mockReviewRequestPage));

      expect(find.text('\$1.00'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
      expect(find.text('\$17.00'), findsOneWidget);
      expect(find.text('MXN'), findsOneWidget);
    });

    testWidgets('should show fee table with service fee and total',
        (tester) async {
      await tester.pumpWidget(
          WidgetHelpers.testableWidget(child: mockReviewRequestPage));

      expect(find.byType(FeeDetails), findsOneWidget);
      expect(find.text('9.00 MXN'), findsOneWidget);
      expect(find.text('26.00 MXN'), findsOneWidget);
    });

    testWidgets('should show bank name', (tester) async {
      await tester.pumpWidget(
          WidgetHelpers.testableWidget(child: mockReviewRequestPage));

      expect(find.text('ABC Bank'), findsOneWidget);
    });

    testWidgets('should show obscured account number', (tester) async {
      await tester.pumpWidget(
          WidgetHelpers.testableWidget(child: mockReviewRequestPage));

      expect(find.textContaining('•'), findsOneWidget);
      expect(find.textContaining('7890'), findsOneWidget);
      expect(find.textContaining('1234567890'), findsNothing);
    });

    testWidgets('should show success page on tap of submit button',
        (tester) async {
      await tester.pumpWidget(
          WidgetHelpers.testableWidget(child: mockReviewRequestPage));

      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(find.byType(SuccessPage), findsOneWidget);
      expect(find.text('Your request was submitted!'), findsOneWidget);
    });
  });
}
