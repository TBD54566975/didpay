import 'package:didpay/features/home/transaction.dart';
import 'package:didpay/features/payment/payment_details_page.dart';
import 'package:didpay/features/payment/payment_method.dart';
import 'package:didpay/features/payment/search_payment_methods_page.dart';
import 'package:didpay/features/payment/search_payment_types_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  group('PaymentDetailsPage', () {
    Widget paymentDetailsPageTestWidget({
      List<Override> overrides = const [],
    }) =>
        WidgetHelpers.testableWidget(
          child: const PaymentDetailsPage(
            payinAmount: '1.00',
            payinCurrency: 'USD',
            exchangeRate: '17',
            payoutAmount: '17.00',
            payoutCurrency: 'MXN',
            transactionType: TransactionType.deposit,
          ),
          overrides: overrides,
        );
    testWidgets('should show header', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(child: paymentDetailsPageTestWidget()),
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
          child: paymentDetailsPageTestWidget(),
          overrides: [
            paymentMethodProvider.overrideWith(
              (ref) => [
                PaymentMethod(
                  kind: 'MOMO_MPESA',
                  name: 'M-Pesa',
                  group: 'Mobile money',
                  requiredPaymentDetails: momoSchema,
                ),
                PaymentMethod(
                  kind: 'BANK_GT BANK',
                  name: 'GT Bank',
                  group: 'Bank',
                  requiredPaymentDetails: momoSchema,
                ),
              ],
            ),
          ],
        ),
      );

      expect(find.text('Select a payment type'), findsOneWidget);
    });

    testWidgets('should not show payment type selector', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: paymentDetailsPageTestWidget(),
          overrides: [
            paymentMethodProvider.overrideWith(
              (ref) => [
                PaymentMethod(
                  kind: 'MOMO_MPESA',
                  name: 'M-Pesa',
                  group: 'Mobile money',
                  requiredPaymentDetails: momoSchema,
                ),
                PaymentMethod(
                  kind: 'MOMO_MTN',
                  name: 'MTN',
                  requiredPaymentDetails: momoSchema,
                ),
              ],
            ),
          ],
        ),
      );

      expect(find.text('Select a payment type'), findsNothing);
    });

    testWidgets('should show payment method selection zero state',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: paymentDetailsPageTestWidget(),
          overrides: [
            paymentMethodProvider.overrideWith(
              (ref) => [
                PaymentMethod(
                  kind: 'MOMO_MPESA',
                  name: 'M-Pesa',
                  requiredPaymentDetails: momoSchema,
                ),
                PaymentMethod(
                  kind: 'MOMO_MTN',
                  name: 'MTN',
                  requiredPaymentDetails: momoSchema,
                ),
              ],
            ),
          ],
        ),
      );

      expect(find.text('Select a payment method'), findsOneWidget);
      expect(find.text('Service fees may apply'), findsOneWidget);
    });

    testWidgets('should show payment method without selector', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: paymentDetailsPageTestWidget(),
          overrides: [
            paymentMethodProvider.overrideWith(
              (ref) => [
                PaymentMethod(
                  kind: 'MOMO_MPESA',
                  name: 'M-Pesa',
                  requiredPaymentDetails: momoSchema,
                ),
              ],
            ),
          ],
        ),
      );

      expect(find.widgetWithText(ListTile, 'M-Pesa'), findsOneWidget);
      expect(find.widgetWithIcon(Icon, Icons.chevron_right), findsNothing);
    });

    testWidgets(
        'should show SearchPaymentTypesPage on tap of select a payment type',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: paymentDetailsPageTestWidget(),
          overrides: [
            paymentMethodProvider.overrideWith(
              (ref) => [
                PaymentMethod(
                  kind: 'MOMO_MPESA',
                  name: 'M-Pesa',
                  group: 'Mobile money',
                  requiredPaymentDetails: momoSchema,
                ),
                PaymentMethod(
                  kind: 'BANK_GT BANK',
                  name: 'GT Bank',
                  group: 'Bank',
                  requiredPaymentDetails: momoSchema,
                ),
              ],
            ),
          ],
        ),
      );

      await tester.tap(find.text('Select a payment type'));
      await tester.pumpAndSettle();
      expect(find.byType(SearchPaymentTypesPage), findsOneWidget);
    });

    testWidgets(
        'should show SearchPaymentMethodsPage on tap of select a payment method',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: paymentDetailsPageTestWidget(),
          overrides: [
            paymentMethodProvider.overrideWith(
              (ref) => [
                PaymentMethod(
                  kind: 'MOMO_MPESA',
                  name: 'M-Pesa',
                  requiredPaymentDetails: momoSchema,
                ),
                PaymentMethod(
                  kind: 'MOMO_MTN',
                  name: 'MTN',
                  requiredPaymentDetails: momoSchema,
                ),
              ],
            ),
          ],
        ),
      );

      await tester.tap(find.text('Select a payment method'));
      await tester.pumpAndSettle();
      expect(find.byType(SearchPaymentMethodsPage), findsOneWidget);
    });

    testWidgets(
        'should show payment type after SearchPaymentTypesPage selection',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: paymentDetailsPageTestWidget(),
          overrides: [
            paymentMethodProvider.overrideWith(
              (ref) => [
                PaymentMethod(
                  kind: 'MOMO_MPESA',
                  name: 'M-Pesa',
                  group: 'Mobile money',
                  requiredPaymentDetails: momoSchema,
                ),
                PaymentMethod(
                  kind: 'BANK_GT BANK',
                  name: 'GT Bank',
                  group: 'Bank',
                  requiredPaymentDetails: momoSchema,
                ),
              ],
            ),
          ],
        ),
      );

      await tester.tap(find.text('Select a payment type'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bank'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ListTile, 'Bank'), findsOneWidget);
    });

    testWidgets(
        'should show payment name after SearchPaymentMethodsPage selection',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: paymentDetailsPageTestWidget(),
          overrides: [
            paymentMethodProvider.overrideWith(
              (ref) => [
                PaymentMethod(
                  kind: 'MOMO_MPESA',
                  name: 'M-Pesa',
                  requiredPaymentDetails: momoSchema,
                ),
                PaymentMethod(
                  kind: 'BANK_GT BANK',
                  name: 'GT Bank',
                  requiredPaymentDetails: momoSchema,
                ),
              ],
            ),
          ],
        ),
      );

      await tester.tap(find.text('Select a payment method'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('M-Pesa'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ListTile, 'M-Pesa'), findsOneWidget);
    });

    testWidgets('should show momo schema form', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: paymentDetailsPageTestWidget(),
          overrides: [
            paymentMethodProvider.overrideWith(
              (ref) => [
                PaymentMethod(
                  kind: 'MOMO_MPESA',
                  name: 'M-Pesa',
                  requiredPaymentDetails: momoSchema,
                ),
              ],
            ),
          ],
        ),
      );

      expect(find.byType(TextFormField), findsExactly(2));
      expect(find.text('Phone number'), findsOneWidget);
      expect(find.text('Reason for sending'), findsOneWidget);
    });

    testWidgets('should show bank schema form', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: paymentDetailsPageTestWidget(),
          overrides: [
            paymentMethodProvider.overrideWith(
              (ref) => [
                PaymentMethod(
                  kind: 'BANK_GT BANK',
                  name: 'GT Bank',
                  requiredPaymentDetails: bankSchema,
                ),
              ],
            ),
          ],
        ),
      );

      expect(find.byType(TextFormField), findsExactly(2));
      expect(find.text('Account number'), findsOneWidget);
      expect(find.text('Reason for sending'), findsOneWidget);
    });

    testWidgets('should show wallet schema form', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: paymentDetailsPageTestWidget(),
          overrides: [
            paymentMethodProvider.overrideWith(
              (ref) => [
                PaymentMethod(
                  kind: 'WALLET_BTC ADDRESS',
                  name: 'BTC Address',
                  requiredPaymentDetails: walletSchema,
                ),
              ],
            ),
          ],
        ),
      );

      expect(find.byType(TextFormField), findsExactly(2));
      expect(find.text('Wallet address'), findsOneWidget);
      expect(find.text('Reason for sending'), findsOneWidget);
    });
  });
}
