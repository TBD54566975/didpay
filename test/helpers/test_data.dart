import 'dart:convert';

import 'package:didpay/features/account/account_balance.dart';
import 'package:didpay/features/feature_flags/feature_flag.dart';
import 'package:didpay/features/pfis/pfi.dart';
import 'package:didpay/features/transaction/transaction.dart';
import 'package:json_schema/json_schema.dart';
import 'package:tbdex/tbdex.dart';
import 'package:typeid/typeid.dart';
import 'package:web5/web5.dart';

class TestData {
  static const String dap = '@username/didpay.me';

  static final _aliceKeyManager = InMemoryKeyManager();
  static final _pfiKeyManager = InMemoryKeyManager();

  static late final BearerDid aliceDid;
  static late final BearerDid pfiDid;

  static Future<void> initializeDids() async {
    aliceDid = await DidDht.create(keyManager: _aliceKeyManager);
    pfiDid = await DidDht.create(keyManager: _pfiKeyManager);
  }

  static Pfi getPfi(String did) => Pfi(did: did);

  static FeatureFlag getFeatureFlag(String name, String description) =>
      FeatureFlag(name: name, description: description);

  static Map<Pfi, List<Offering>> getOfferingsMap() => {
        Pfi(did: pfiDid.uri): [getOffering()],
      };

  static List<Pfi> getPfis() => [Pfi(did: pfiDid.uri)];

  static AccountBalance getAccountBalance() =>
      AccountBalance(total: '101', currencyCode: 'USD', balancesMap: {});

  static Offering getOffering({
    PresentationDefinition? requiredClaims,
    List<PayinMethod>? payinMethods,
    List<PayoutMethod>? payoutMethods,
  }) =>
      Offering.create(
        pfiDid.uri,
        OfferingData(
          description: 'A sample offering',
          payoutUnitsPerPayinUnit: '10',
          payin: PayinDetails(
            currencyCode: 'AUD',
            min: '0.01',
            max: '100.00',
            methods: payinMethods ??
                [
                  PayinMethod(
                    kind: 'DEBIT_CARD',
                    requiredPaymentDetails: paymentDetailsSchema(),
                  ),
                ],
          ),
          payout: PayoutDetails(
            currencyCode: 'USD',
            methods: payoutMethods ??
                [
                  PayoutMethod(
                    estimatedSettlementTime: 0,
                    kind: 'DEBIT_CARD',
                    requiredPaymentDetails: paymentDetailsSchema(),
                  ),
                ],
          ),
          requiredClaims: requiredClaims,
        ),
      );

  static Exchange getExchange() => [getQuote()];

  static Rfq getRfq() => Rfq.create(
        aliceDid.uri,
        pfiDid.uri,
        CreateRfqData(
          offeringId: '123',
          payin: CreateSelectedPayinMethod(
            amount: '100',
            kind: 'DEBIT_CARD',
          ),
          payout: CreateSelectedPayoutMethod(
            kind: 'DEBIT_CARD',
          ),
        ),
      );

  static Quote getQuote() => Quote.create(
        aliceDid.uri,
        pfiDid.uri,
        TypeId.generate(MessageKind.rfq.name),
        QuoteData(
          expiresAt: '2022-01-01T00:00:00Z',
          payoutUnitsPerPayinUnit: '1',
          payin: QuoteDetails(
            currencyCode: 'AUD',
            subtotal: '100',
            total: '100.01',
            fee: '0.01',
          ),
          payout: QuoteDetails(
            currencyCode: 'BTC',
            subtotal: '0.10',
            total: '0.12',
            fee: '0.02',
          ),
        ),
      );

  static Order getOrder({String? to}) => Order.create(
        to ?? pfiDid.uri,
        aliceDid.uri,
        TypeId.generate(MessageKind.rfq.name),
      );

  static JsonSchema paymentDetailsSchema() => JsonSchema.create(
        jsonDecode(r'''
        {
          "$schema": "http://json-schema.org/draft-07/schema#",
          "type": "object",
          "properties": {
            "cardNumber": {
              "type": "string",
              "description": "The 16-digit debit card number",
              "minLength": 16,
              "maxLength": 16
            },
            "expiryDate": {
              "type": "string",
              "description": "The expiry date of the card in MM/YY format",
              "pattern": "^(0[1-9]|1[0-2])\\/([0-9]{2})$"
            },
            "cardHolderName": {
              "type": "string",
              "description": "Name of the cardholder as it appears on the card"
            },
            "cvv": {
              "type": "string",
              "description": "The 3-digit CVV code",
              "minLength": 3,
              "maxLength": 3
            }
          },
          "required": ["cardNumber", "expiryDate", "cardHolderName", "cvv"],
          "additionalProperties": false
        }
    '''),
      );

  static Transaction getTransaction({
    TransactionType type = TransactionType.send,
  }) =>
      Transaction(
        payinAmount: '100.01',
        payoutAmount: '0.12',
        payinCurrency: 'AUD',
        payoutCurrency: 'BTC',
        createdAt: DateTime(2024),
        type: type,
        status: TransactionStatus.orderSubmitted,
      );
}
