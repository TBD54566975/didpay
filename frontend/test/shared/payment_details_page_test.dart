import 'package:flutter/material.dart';
import 'package:flutter_starter/shared/payment_details_page.dart';
import 'package:flutter_starter/shared/payment_method.dart';
import 'package:flutter_starter/shared/search_payment_methods_page.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/widget_helpers.dart';

void main() {
  group('PaymentDetailsPage', () {
    testWidgets('should show make sure this information is correct',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const PaymentDetailsPage(),
        ),
      );

      expect(
          find.text('Make sure this information is correct.'), findsOneWidget);
    });

    testWidgets('should show next button', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const PaymentDetailsPage(),
        ),
      );

      expect(find.widgetWithText(FilledButton, 'Next'), findsOneWidget);
    });

    testWidgets('should show enter your momo details', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const PaymentDetailsPage(),
          overrides: [
            paymentMethodProvider.overrideWith(
              (ref) => [
                PaymentMethod(
                  kind: 'MOMO_MPESA',
                  requiredPaymentDetails: momoSchema,
                ),
              ],
            ),
          ],
        ),
      );

      expect(find.text('Enter your momo details'), findsOneWidget);
    });

    testWidgets('should show enter your bank details', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const PaymentDetailsPage(),
          overrides: [
            paymentMethodProvider.overrideWith(
              (ref) => [
                PaymentMethod(
                  kind: 'BANK_GT BANK',
                  requiredPaymentDetails: bankSchema,
                ),
              ],
            ),
          ],
        ),
      );

      expect(find.text('Enter your bank details'), findsOneWidget);
    });

    testWidgets('should show enter your wallet details', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const PaymentDetailsPage(),
          overrides: [
            paymentMethodProvider.overrideWith(
              (ref) => [
                PaymentMethod(
                  kind: 'WALLET_BTC ADDRESS',
                  requiredPaymentDetails: walletSchema,
                ),
              ],
            ),
          ],
        ),
      );

      expect(find.text('Enter your wallet details'), findsOneWidget);
    });

    testWidgets('should show no payment type segments', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const PaymentDetailsPage(),
          overrides: [
            paymentMethodProvider.overrideWith(
              (ref) => [
                PaymentMethod(
                  kind: 'MOMO_MPESA',
                  requiredPaymentDetails: momoSchema,
                ),
              ],
            ),
          ],
        ),
      );

      expect(find.byType(SegmentedButton<String>), findsNothing);
    });

    testWidgets('should show momo and bank payment type segments',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const PaymentDetailsPage(),
          overrides: [
            paymentMethodProvider.overrideWith(
              (ref) => [
                PaymentMethod(
                  kind: 'MOMO_MPESA',
                  requiredPaymentDetails: momoSchema,
                ),
                PaymentMethod(
                  kind: 'BANK_GT BANK',
                  requiredPaymentDetails: bankSchema,
                ),
              ],
            ),
          ],
        ),
      );

      expect(find.byType(SegmentedButton<String?>), findsOneWidget);
      expect(find.widgetWithText(SegmentedButton<String?>, 'MOMO'),
          findsOneWidget);
      expect(find.widgetWithText(SegmentedButton<String?>, 'BANK'),
          findsOneWidget);
    });

    testWidgets('should show momo, bank, and wallet payment type segments',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const PaymentDetailsPage(),
          overrides: [
            paymentMethodProvider.overrideWith(
              (ref) => [
                PaymentMethod(
                  kind: 'MOMO_MPESA',
                  requiredPaymentDetails: momoSchema,
                ),
                PaymentMethod(
                  kind: 'BANK_GT BANK',
                  requiredPaymentDetails: bankSchema,
                ),
                PaymentMethod(
                  kind: 'WALLET_BTC ADDRESS',
                  requiredPaymentDetails: walletSchema,
                ),
              ],
            ),
          ],
        ),
      );

      expect(find.byType(SegmentedButton<String?>), findsOneWidget);
      expect(find.widgetWithText(SegmentedButton<String?>, 'MOMO'),
          findsOneWidget);
      expect(find.widgetWithText(SegmentedButton<String?>, 'BANK'),
          findsOneWidget);
      expect(find.widgetWithText(SegmentedButton<String?>, 'WALLET'),
          findsOneWidget);
    });

    testWidgets('should show payment provider', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const PaymentDetailsPage(),
          overrides: [
            paymentMethodProvider.overrideWith(
              (ref) => [
                PaymentMethod(
                  kind: 'MOMO_MPESA',
                  requiredPaymentDetails: momoSchema,
                ),
              ],
            ),
          ],
        ),
      );
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'MPESA'), findsOneWidget);
      expect(find.textContaining('Service fee: 0.0'), findsOneWidget);
    });

    testWidgets('should show momo schema form', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const PaymentDetailsPage(),
          overrides: [
            paymentMethodProvider.overrideWith(
              (ref) => [
                PaymentMethod(
                  kind: 'MOMO_MPESA',
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
          child: const PaymentDetailsPage(),
          overrides: [
            paymentMethodProvider.overrideWith(
              (ref) => [
                PaymentMethod(
                  kind: 'BANK_GT BANK',
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
          child: const PaymentDetailsPage(),
          overrides: [
            paymentMethodProvider.overrideWith(
              (ref) => [
                PaymentMethod(
                  kind: 'WALLET_BTC ADDRESS',
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

    testWidgets(
        'should show PaymentMethodsPage when payment provider is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const PaymentDetailsPage(),
          overrides: [
            paymentMethodProvider.overrideWith(
              (ref) => [
                PaymentMethod(
                  kind: 'MOMO_MPESA',
                  requiredPaymentDetails: walletSchema,
                ),
              ],
            ),
          ],
        ),
      );

      await tester.tap(find.text('MPESA'));
      await tester.pumpAndSettle();
      expect(find.byType(SearchPaymentMethodsPage), findsOneWidget);
    });
  });
}
