import 'dart:convert';

import 'package:didpay/features/feature_flags/feature_flags_notifier.dart';
import 'package:didpay/features/feature_flags/lucid/lucid_offerings_page.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbdex/tbdex.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/widget_helpers.dart';

void main() {
  const jsonString =
      r'''[{"metadata":{"kind":"offering","from":"did:web:localhost%3A8892:ingress","id":"offering_01hv22zfv1eptadkm92v278gh9","protocol":"1.0","createdAt":"2024-04-12T20:57:11Z","updatedAt":"2024-04-12T20:57:11Z"},"data":{"description":"MXN for USD","payoutUnitsPerPayinUnit":"16.34","payin":{"currencyCode":"USD","methods":[{"kind":"STORED_BALANCE","name":"Account balance"}]},"payout":{"currencyCode":"MXN","methods":[{"kind":"SPEI","estimatedSettlementTime":300,"name":"SPEI","requiredPaymentDetails":{"$schema":"http://json-schema.org/draft-07/schema#","additionalProperties":false,"properties":{"clabe":{"type":"string"},"fullName":{"type":"string"}},"required":["clabe","fullName"]}}]}},"signature":"eyJhbGciOiJFZERTQSIsImtpZCI6ImRpZDp3ZWI6bG9jYWxob3N0JTNBODg5MjppbmdyZXNzIzAifQ..le65W3WyI2UKMJojADv_lTQixt0wDmnMMBVaWC_2BaYVQfe8HY3gQyPqbI4dT-iDNRjg_EdlCvTiEzANfp0lDw"}]''';
  const pfi = Pfi(did: 'did:web:x%3A8892:ingress');

  final jsonList = jsonDecode(jsonString) as List<dynamic>;
  final offerings = {
    pfi: [Offering.fromJson(jsonList[0])],
  };
  late MockTbdexService mockTbdexService;
  late MockPfisNotifier mockPfisNotifier;
  late MockFeatureFlagsNotifier mockFeatureFlagsNotifier;

  setUp(() {
    mockTbdexService = MockTbdexService();
    mockPfisNotifier = MockPfisNotifier([pfi]);
    mockFeatureFlagsNotifier = MockFeatureFlagsNotifier([]);

    when(
      () => mockTbdexService.getOfferings([pfi]),
    ).thenAnswer((_) async => offerings);
  });

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
        find.widgetWithText(ListTile, 'USD → MXN'),
        findsOneWidget,
      );
    });
  });
}
