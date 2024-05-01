import 'dart:convert';

import 'package:didpay/features/countries/country.dart';
import 'package:didpay/features/payin/payin.dart';
import 'package:didpay/features/payout/payout.dart';
import 'package:didpay/features/remittance/remittance_page.dart';
import 'package:didpay/features/tbdex/rfq_state.dart';
import 'package:didpay/features/tbdex/tbdex_providers.dart';
import 'package:didpay/shared/fee_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbdex/tbdex.dart';

import '../../helpers/widget_helpers.dart';

void main() {
  const jsonString =
      r'''[{"metadata":{"kind":"offering","from":"did:web:localhost%3A8892:ingress","id":"offering_01hv22zfv1eptadkm92v278gh9","protocol":"1.0","createdAt":"2024-04-12T20:57:11Z","updatedAt":"2024-04-12T20:57:11Z"},"data":{"description":"MXN for USD","payoutUnitsPerPayinUnit":"16.34","payin":{"currencyCode":"USD","methods":[{"kind":"STORED_BALANCE","name":"Account balance"}]},"payout":{"currencyCode":"MXN","methods":[{"kind":"SPEI","estimatedSettlementTime":300,"name":"SPEI","requiredPaymentDetails":{"$schema":"http://json-schema.org/draft-07/schema#","additionalProperties":false,"properties":{"clabe":{"type":"string"},"fullName":{"type":"string"}},"required":["clabe","fullName"]}}]}},"signature":"eyJhbGciOiJFZERTQSIsImtpZCI6ImRpZDp3ZWI6bG9jYWxob3N0JTNBODg5MjppbmdyZXNzIzAifQ..le65W3WyI2UKMJojADv_lTQixt0wDmnMMBVaWC_2BaYVQfe8HY3gQyPqbI4dT-iDNRjg_EdlCvTiEzANfp0lDw"}]''';

  final jsonList = jsonDecode(jsonString) as List<dynamic>;
  final offerings = [Offering.fromJson(jsonList[0])];
  const country = Country(name: 'United States', code: 'US');

  group('RemittancePage', () {
    testWidgets('should show payin and payout', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const RemittancePage(
            country: country,
            rfqState: RfqState(),
          ),
          overrides: [
            offeringsProvider.overrideWith((ref, did) async => offerings),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Payin), findsOneWidget);
      expect(find.byType(Payout), findsOneWidget);
    });

    testWidgets('should show fee details', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const RemittancePage(
            country: country,
            rfqState: RfqState(),
          ),
          overrides: [
            offeringsProvider.overrideWith((ref, did) async => offerings),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FeeDetails), findsOneWidget);
    });

    testWidgets('should show next button', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const RemittancePage(
            country: country,
            rfqState: RfqState(),
          ),
          overrides: [
            offeringsProvider.overrideWith((ref, did) async => offerings),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(FilledButton, 'Next'), findsOneWidget);
    });

    testWidgets('should change deposit input amount after number pad press',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const RemittancePage(
            country: country,
            rfqState: RfqState(),
          ),
          overrides: [
            offeringsProvider.overrideWith((ref, did) async => offerings),
          ],
        ),
      );
      await tester.pumpAndSettle();

      for (var i = 1; i <= 9; i++) {
        await tester.tap(find.text('$i'));
        await tester.pumpAndSettle();

        expect(find.text('$i'), findsAtLeast(1));

        await tester.tap(find.text('<'));
        await tester.pumpAndSettle();
      }
    });
  });
}
