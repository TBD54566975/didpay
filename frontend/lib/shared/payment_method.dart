import 'package:hooks_riverpod/hooks_riverpod.dart';

// TODO: remove this file when FTL generated types are available
class PaymentMethod {
  final String kind;
  final String requiredPaymentDetails;
  final String? fee;

  PaymentMethod({
    required this.kind,
    required this.requiredPaymentDetails,
    this.fee,
  });
}

final paymentMethodProvider = StateProvider<List<PaymentMethod>>((ref) {
  return [
    PaymentMethod(
      kind: 'BTC_ADDRESS WALLET',
      requiredPaymentDetails: walletSchema,
    ),
    PaymentMethod(
      kind: 'MOMO_MTN',
      requiredPaymentDetails: momoSchema,
    ),
    PaymentMethod(
      kind: 'MOMO_MPESA',
      requiredPaymentDetails: momoSchema,
    ),
    PaymentMethod(
      kind: 'BANK_Access Bank',
      requiredPaymentDetails: bankSchema,
      fee: '10.0',
    ),
  ];
});

const String bankSchema = '''
  {
    "properties": {
      "accountNumber": {
        "type": "string",
        "title": "Account Number",
        "description": "Bank account number of the recipient",
        "minLength": 10,
        "maxLength": 10
      },
      "reason": {
        "title": "Reason for sending",
        "description": "To abide by the travel rules and financial reporting requirements, the reason for sending money",
        "type": "string"
      }
    },
    "required": [
      "accountNumber",
      "reason"
    ],
    "additionalProperties": false
  }''';

const String momoSchema = '''
  {
    "properties": {
      "accountNumber": {
        "type": "string",
        "title": "Phone Number",
        "description": "Mobile money account number of the recipient",
        "minLength": 12,
        "maxLength": 12
      },
      "reason": {
        "title": "Reason for sending",
        "description": "To abide by the travel rules and financial reporting requirements, the reason for sending money",
        "type": "string"
      }
    },
    "required": [
      "accountNumber",
      "reason"
    ],
    "additionalProperties": false
  }''';

const String walletSchema = '''
  {
    "properties": {
      "walletAddress": {
        "type": "string",
        "description": "Your wallet address",
        "title": "BTC Address"
      },
      "reason": {
        "title": "Reason for sending",
        "description": "To abide by the travel rules and financial reporting requirements, the reason for sending money",
        "type": "string"
      }
    },
    "required": [
      "walletAddress",
      "reason"
    ],
    "additionalProperties": false
  }''';
