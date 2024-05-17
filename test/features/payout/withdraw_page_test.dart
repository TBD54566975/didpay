import 'dart:convert';

import 'package:didpay/features/payin/payin.dart';
import 'package:didpay/features/payout/payout.dart';
import 'package:didpay/features/payout/withdraw_page.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/pfis/pfis_notifier.dart';
import 'package:didpay/features/tbdex/rfq_state.dart';
import 'package:didpay/features/tbdex/tbdex_service.dart';
import 'package:didpay/shared/fee_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tbdex/tbdex.dart';

import '../../helpers/mocks.dart';
import '../../helpers/widget_helpers.dart';

void main() {
  const jsonString =
      r'''[{"metadata":{"kind":"offering","from":"did:web:localhost%3A8892:ingress","id":"offering_01hv22zfv1eptadkm92v278gh9","protocol":"1.0","createdAt":"2024-04-12T20:57:11Z","updatedAt":"2024-04-12T20:57:11Z"},"data":{"description":"MXN for USD","payoutUnitsPerPayinUnit":"16.34","payin":{"currencyCode":"USD","methods":[{"kind":"STORED_BALANCE","name":"Account balance"}]},"payout":{"currencyCode":"MXN","methods":[{"kind":"SPEI","estimatedSettlementTime":300,"name":"SPEI","requiredPaymentDetails":{"$schema":"http://json-schema.org/draft-07/schema#","additionalProperties":false,"properties":{"clabe":{"type":"string"},"fullName":{"type":"string"}},"required":["clabe","fullName"]}}]}},"signature":"eyJhbGciOiJFZERTQSIsImtpZCI6ImRpZDp3ZWI6bG9jYWxob3N0JTNBODg5MjppbmdyZXNzIzAifQ..le65W3WyI2UKMJojADv_lTQixt0wDmnMMBVaWC_2BaYVQfe8HY3gQyPqbI4dT-iDNRjg_EdlCvTiEzANfp0lDw"}]''';

  final jsonList = jsonDecode(jsonString) as List<dynamic>;
  final offerings = [Offering.fromJson(jsonList[0])];
  late MockTbdexService mockTbdexService;

  group('WithdrawPage', () {
    setUp(() {
      mockTbdexService = MockTbdexService();

      when(
        () => mockTbdexService
            .getOfferings([const Pfi(did: 'did:web:x%3A8892:ingress')]),
      ).thenAnswer((_) async => offerings);
    });
    testWidgets('should show Currency Converter', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const WithdrawPage(
            rfqState: RfqState(),
          ),
          overrides: [
            tbdexServiceProvider.overrideWith((ref) => mockTbdexService),
            pfisProvider.overrideWith((ref) => MockPfisNotifier()),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Payin), findsOneWidget);
      expect(find.byType(Payout), findsOneWidget);
    });

    testWidgets('should show Fee Details', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const WithdrawPage(
            rfqState: RfqState(),
          ),
          overrides: [
            tbdexServiceProvider.overrideWith((ref) => mockTbdexService),
            pfisProvider.overrideWith((ref) => MockPfisNotifier()),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FeeDetails), findsOneWidget);
    });

    testWidgets('should show next button', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const WithdrawPage(
            rfqState: RfqState(),
          ),
          overrides: [
            tbdexServiceProvider.overrideWith((ref) => mockTbdexService),
            pfisProvider.overrideWith((ref) => MockPfisNotifier()),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithText(FilledButton, 'Next'), findsOneWidget);
    });

    testWidgets('should change withdraw input amount after number pad press',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const WithdrawPage(
            rfqState: RfqState(),
          ),
          overrides: [
            tbdexServiceProvider.overrideWith((ref) => mockTbdexService),
            pfisProvider.overrideWith((ref) => MockPfisNotifier()),
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

    testWidgets(
        'should show the currency list on tap of the currency converter dropdown toggle',
        (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: const WithdrawPage(
            rfqState: RfqState(),
          ),
          overrides: [
            tbdexServiceProvider.overrideWith((ref) => mockTbdexService),
            pfisProvider.overrideWith((ref) => MockPfisNotifier()),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
