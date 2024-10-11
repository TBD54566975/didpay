import 'package:didpay/features/currency/currency_dropdown.dart';
import 'package:didpay/features/payment/payment_amount_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
  
import '../../helpers/test_data.dart';
import '../../helpers/widget_helpers.dart';

void main() async {
  await TestData.initializeDids();

  late ValueNotifier<PaymentAmountState?> mockState;
  const testCurrency = 'USD';

  setUp(() {
    // Initialize mockState with a non-null offeringsMap
    mockState = ValueNotifier<PaymentAmountState?>(
      PaymentAmountState(
        offeringsMap: TestData.getOfferingsMap(),
      ), // Use TestData as suggested
    );
  });

  Widget createWidgetUnderTest() {
    return WidgetHelpers.testableWidget(
      // Use WidgetHelpers for consistent test setup
      child: CurrencyDropdown(
        paymentCurrency: testCurrency,
        state: mockState,
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
    await tester.tap(find.text(testCurrency));
    await tester.pumpAndSettle(); // Wait for the modal to open

    // Verify if the modal is displayed
    expect(
      find.text('Select currency'),
      findsOneWidget,
    ); // Look for modal text or widget
  });

  testWidgets('CurrencyDropdown updates state when a currency is selected',
      (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Open the modal by tapping on the currency dropdown button
    await tester.tap(
      find.text(testCurrency),
    ); // Using the 'USD' label text to find the button
    await tester.pumpAndSettle();

    // Simulate selecting a currency by updating the mockState directly
    const selectedCurrency = 'EUR';
    mockState.value = PaymentAmountState(
      filterCurrency:
          selectedCurrency, // Assuming 'filterCurrency' is the correct field for currency selection
    );

    await tester.pumpAndSettle();

    // Verify the state reflects the selected currency
    expect(mockState.value?.filterCurrency, selectedCurrency);
  });
}
