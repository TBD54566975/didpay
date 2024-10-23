import 'package:didpay/features/currency/currency_dropdown.dart';
import 'package:didpay/features/payment/payment_amount_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_data.dart';
import '../../helpers/widget_helpers.dart';

void main() async {
  await TestData.initializeDids();

  final testOffering = TestData.getOfferingsMap(payoutCurrencies: ['EUR', 'USD']);
  final mockState = ValueNotifier<PaymentAmountState?>(
    PaymentAmountState(
      offeringsMap: testOffering,
      selectedOffering: testOffering.values.first.first,
    ),
  );

  Widget currencyDropdownTestWidget(String testCurrency) {
    return WidgetHelpers.testableWidget(
      child: CurrencyDropdown(
        paymentCurrency: testCurrency,
        state: mockState,
      ),
    );
  }

  testWidgets('should display the initial currency in CurrencyDropdown', (tester) async {
    const testCurrency = 'USD';    
    await tester.pumpWidget(currencyDropdownTestWidget(testCurrency));

    expect(find.text(testCurrency), findsOneWidget);
  });

  testWidgets('should open Select Currency modal on tap in CurrencyDropdown', (tester) async {
    const testCurrency = 'USD';    
    await tester.pumpWidget(currencyDropdownTestWidget(testCurrency));

    await tester.tap(find.text(testCurrency));
    await tester.pumpAndSettle();
    
    expect(find.text('Select currency'), findsOneWidget);
  });

  testWidgets('should update PaymentAmountState when a new offering is selected in CurrencyDropdown', (tester) async {
    const testCurrency = 'EUR';
    await tester.pumpWidget(currencyDropdownTestWidget(testCurrency));

    await tester.tap(find.text(testCurrency));
    await tester.pumpAndSettle();

    const selectedCurrency = 'EUR';
    await tester.tap(find.text(selectedCurrency));

    await tester.pumpAndSettle();

    expect(mockState.value?.payoutCurrency, selectedCurrency);
  });
}
