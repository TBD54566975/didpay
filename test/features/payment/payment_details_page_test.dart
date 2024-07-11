import 'package:didpay/features/did/did_provider.dart';
import 'package:didpay/features/payment/payment_amount_state.dart';
import 'package:didpay/features/payment/payment_details_page.dart';
import 'package:didpay/features/payment/payment_details_state.dart';
import 'package:didpay/features/payment/payment_method.dart';
import 'package:didpay/features/payment/payment_methods_page.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/payment/payment_types_page.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbdex/tbdex.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_data.dart';
import '../../helpers/widget_helpers.dart';

void main() async {
  await TestData.initializeDids();

  final did = TestData.aliceDid;
  final schema = TestData.paymentDetailsSchema();

  late MockPfisNotifier mockPfisNotifier;

  group('PaymentDetailsPage', () {
    setUp(() {
      mockPfisNotifier = MockPfisNotifier([]);
    });

    Widget paymentDetailsPageTestWidget({Offering? offering}) =>
        WidgetHelpers.testableWidget(
          child: PaymentDetailsPage(
            paymentState: PaymentState(
              transactionType: TransactionType.deposit,
              paymentAmountState: PaymentAmountState(
                payinAmount: '100',
                payoutAmount: '1000',
                pfiDid: did.uri,
                selectedOffering: offering ?? TestData.getOffering(),
              ),
              paymentDetailsState: PaymentDetailsState(
                paymentMethods: offering?.data.payin.methods
                    .map(PaymentMethod.fromPayinMethod)
                    .toList(),
              ),
            ),
          ),
          overrides: [
            didProvider.overrideWithValue(did),
            pfisProvider.overrideWith((ref) => mockPfisNotifier),
          ],
        );

    testWidgets('should show header', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: paymentDetailsPageTestWidget(),
        ),
      );

      expect(find.text('Enter your payment details'), findsOneWidget);
      expect(
        find.text('Make sure this information is correct.'),
        findsOneWidget,
      );
    });

    testWidgets('should show payment type selection zero state',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: paymentDetailsPageTestWidget(
            offering: TestData.getOffering(
              payinMethods: [
                PayinMethod(
                  kind: 'MOMO_MPESA',
                  name: 'M-Pesa',
                  group: 'Mobile money',
                ),
                PayinMethod(
                  kind: 'BANK_GT BANK',
                  name: 'GT Bank',
                  group: 'Bank',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Select a payment type'), findsOneWidget);
    });

    testWidgets('should not show payment type selector', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: paymentDetailsPageTestWidget(
            offering: TestData.getOffering(
              payinMethods: [
                PayinMethod(
                  kind: 'MOMO_MPESA',
                  name: 'M-Pesa',
                  group: 'Mobile money',
                ),
                PayinMethod(
                  kind: 'MOMO_MTN',
                  name: 'MTN',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Select a payment type'), findsNothing);
    });

    testWidgets('should show payment method selection zero state',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: paymentDetailsPageTestWidget(
            offering: TestData.getOffering(
              payinMethods: [
                PayinMethod(
                  kind: 'MOMO_MPESA',
                  name: 'M-Pesa',
                ),
                PayinMethod(
                  kind: 'MOMO_MTN',
                  name: 'MTN',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Select a payment method'), findsOneWidget);
      expect(find.text('Service fees may apply'), findsOneWidget);
    });

    testWidgets('should show payment method without selector', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: paymentDetailsPageTestWidget(
            offering: TestData.getOffering(
              payinMethods: [
                PayinMethod(
                  kind: 'MOMO_MPESA',
                  name: 'M-Pesa',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.widgetWithText(ListTile, 'M-Pesa'), findsOneWidget);
      expect(find.widgetWithIcon(Icon, Icons.chevron_right), findsNothing);
    });

    testWidgets('should show PaymentTypesPage on tap of select a payment type',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: paymentDetailsPageTestWidget(
            offering: TestData.getOffering(
              payinMethods: [
                PayinMethod(
                  kind: 'MOMO_MPESA',
                  name: 'M-Pesa',
                  group: 'Mobile money',
                ),
                PayinMethod(
                  kind: 'BANK_GT BANK',
                  name: 'GT Bank',
                  group: 'Bank',
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Select a payment type'));
      await tester.pumpAndSettle();
      expect(find.byType(PaymentTypesPage), findsOneWidget);
    });

    testWidgets(
        'should show PaymentMethodsPage on tap of select a payment method',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: paymentDetailsPageTestWidget(
            offering: TestData.getOffering(
              payinMethods: [
                PayinMethod(
                  kind: 'MOMO_MPESA',
                  name: 'M-Pesa',
                ),
                PayinMethod(
                  kind: 'MOMO_MTN',
                  name: 'MTN',
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Select a payment method'));
      await tester.pumpAndSettle();
      expect(find.byType(PaymentMethodsPage), findsOneWidget);
    });

    testWidgets('should show payment type after PaymentTypesPage selection',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: paymentDetailsPageTestWidget(
            offering: TestData.getOffering(
              payinMethods: [
                PayinMethod(
                  kind: 'MOMO_MPESA',
                  name: 'M-Pesa',
                  group: 'Mobile money',
                ),
                PayinMethod(
                  kind: 'BANK_GT BANK',
                  name: 'GT Bank',
                  group: 'Bank',
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Select a payment type'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bank'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ListTile, 'Bank'), findsOneWidget);
    });

    testWidgets('should show payment name after PaymentMethodsPage selection',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: paymentDetailsPageTestWidget(
            offering: TestData.getOffering(
              payinMethods: [
                PayinMethod(
                  kind: 'MOMO_MPESA',
                  name: 'M-Pesa',
                ),
                PayinMethod(
                  kind: 'BANK_GT BANK',
                  name: 'GT Bank',
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Select a payment method'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('M-Pesa'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ListTile, 'M-Pesa'), findsOneWidget);
    });

    testWidgets('should show schema form', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: paymentDetailsPageTestWidget(
            offering: TestData.getOffering(
              payinMethods: [
                PayinMethod(
                  kind: 'test',
                  name: 'test',
                  requiredPaymentDetails: schema,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsExactly(4));
      expect(find.text('cardNumber'), findsOneWidget);
      expect(find.text('expiryDate'), findsOneWidget);
      expect(find.text('cardHolderName'), findsOneWidget);
      expect(find.text('cvv'), findsOneWidget);
    });
  });
}
