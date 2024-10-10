import 'package:didpay/features/currency/currency_dropdown.dart';
import 'package:didpay/features/payment/payment_amount_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  late ValueNotifier<PaymentAmountState?> mockState;
  const testCurrency = 'USD';

  setUp(() {
    mockState = ValueNotifier<PaymentAmountState?>(null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: CurrencyDropdown(
          paymentCurrency: testCurrency,
          state: mockState,
        ),
      ),
    );
  }

  testWidgets('CurrencyDropdown shows the correct initial currency',
      (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Check if the currency label displays the initial currency
    expect(find.text(testCurrency), findsOneWidget);
  });

  testWidgets('CurrencyDropdown opens the Select Currency modal when tapped',
      (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Tap on the currency dropdown button
    await tester.tap(find.byKey(const Key('currencyDropdownButton')));
    await tester.pumpAndSettle(); // Wait for the modal to open

    // Verify if the modal is displayed
    expect(
      find.text('Select currency'),
      findsOneWidget,
    ); // Look for modal text or widget
  });
}
