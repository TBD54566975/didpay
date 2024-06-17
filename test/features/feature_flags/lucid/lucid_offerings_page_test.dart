import 'package:didpay/features/feature_flags/feature_flags_notifier.dart';
import 'package:didpay/features/feature_flags/lucid/lucid_offerings_page.dart';
import 'package:didpay/features/payment/payment_state.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/test_data.dart';
import '../../../helpers/widget_helpers.dart';

void main() async {
  await TestData.initializeDids();

  final pfis = TestData.getPfis();
  final offerings = TestData.getOfferingsMap();

  late MockTbdexService mockTbdexService;
  late MockPfisNotifier mockPfisNotifier;
  late MockFeatureFlagsNotifier mockFeatureFlagsNotifier;

  setUp(() {
    mockTbdexService = MockTbdexService();
    mockPfisNotifier = MockPfisNotifier(pfis);
    mockFeatureFlagsNotifier = MockFeatureFlagsNotifier([]);

    when(
      () => mockTbdexService.getOfferings(any(), pfis),
    ).thenAnswer((_) async => offerings);
  });

  setUpAll(
    () => registerFallbackValue(
      const PaymentState(transactionType: TransactionType.send),
    ),
  );

  group('LucidOfferingsPage', () {
    Widget lucidOfferingsPageTestWidget() => WidgetHelpers.testableWidget(
          child: const LucidOfferingsPage(),
          overrides: [
            tbdexServiceProvider.overrideWith((ref) => mockTbdexService),
            pfisProvider.overrideWith((ref) => mockPfisNotifier),
            featureFlagsProvider
                .overrideWith((ref) => mockFeatureFlagsNotifier),
          ],
        );

    testWidgets('should show header', (tester) async {
      await tester.pumpWidget(lucidOfferingsPageTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Lucid mode'), findsOneWidget);
      expect(
        find.text('Select from an unfiltered list of all your PFI offerings.'),
        findsOneWidget,
      );
    });

    testWidgets('should show loading indicator while fetching', (tester) async {
      await tester.pumpWidget(lucidOfferingsPageTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show offerings', (tester) async {
      await tester.pumpWidget(lucidOfferingsPageTestWidget());
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(ListTile, 'AUD → USD'),
        findsOneWidget,
      );
    });
  });
}
