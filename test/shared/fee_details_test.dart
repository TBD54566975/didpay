import 'dart:convert';

import 'package:didpay/features/transaction/transaction.dart';
import 'package:didpay/shared/fee_details.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tbdex/tbdex.dart';

import '../helpers/widget_helpers.dart';

void main() {
  const jsonString =
      r'''{"metadata":{"kind":"offering","from":"did:web:localhost%3A8892:ingress","id":"offering_01hv22zfv1eptadkm92v278gh9","protocol":"1.0","createdAt":"2024-04-12T20:57:11Z","updatedAt":"2024-04-12T20:57:11Z"},"data":{"description":"MXN for USD","payoutUnitsPerPayinUnit":"16.34","payin":{"currencyCode":"USD","methods":[{"kind":"STORED_BALANCE","name":"Account balance"}]},"payout":{"currencyCode":"MXN","methods":[{"kind":"SPEI","estimatedSettlementTime":300,"name":"SPEI","requiredPaymentDetails":{"$schema":"http://json-schema.org/draft-07/schema#","additionalProperties":false,"properties":{"clabe":{"type":"string"},"fullName":{"type":"string"}},"required":["clabe","fullName"]}}]}},"signature":"eyJhbGciOiJFZERTQSIsImtpZCI6ImRpZDp3ZWI6bG9jYWxob3N0JTNBODg5MjppbmdyZXNzIzAifQ..le65W3WyI2UKMJojADv_lTQixt0wDmnMMBVaWC_2BaYVQfe8HY3gQyPqbI4dT-iDNRjg_EdlCvTiEzANfp0lDw"}''';

  final json = jsonDecode(jsonString);
  final offering = Offering.fromJson(json);

  group('FeeDetails', () {
    testWidgets('should show est rate label', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: FeeDetails(
            transactionType: TransactionType.deposit,
            offering: offering.data,
          ),
        ),
      );

      expect(find.text('Est. rate'), findsOneWidget);
    });

    testWidgets('should show deposit fee label', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: FeeDetails(
            transactionType: TransactionType.deposit,
            offering: offering.data,
          ),
        ),
      );

      expect(find.text('Deposit fee'), findsOneWidget);
    });

    testWidgets('should show withdraw fee label', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: FeeDetails(
            transactionType: TransactionType.withdraw,
            offering: offering.data,
          ),
        ),
      );

      expect(find.text('Withdraw fee'), findsOneWidget);
    });

    testWidgets('should show send fee label', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: FeeDetails(
            transactionType: TransactionType.send,
            offering: offering.data,
          ),
        ),
      );

      expect(find.text('Send fee'), findsOneWidget);
    });

    testWidgets('should show est rate', (tester) async {
      await tester.pumpWidget(
        WidgetHelpers.testableWidget(
          child: FeeDetails(
            transactionType: TransactionType.deposit,
            offering: offering.data,
          ),
        ),
      );

      expect(find.textContaining('1 USD = 16.34 MXN'), findsOneWidget);
    });
  });
}
