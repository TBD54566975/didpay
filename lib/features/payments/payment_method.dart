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

final _defaultList = [
  PaymentMethod(
    kind: 'BANK_ACCESS BANK',
    requiredPaymentDetails: bankSchema,
    fee: '9.0',
  ),
  PaymentMethod(
    kind: 'BANK_GT BANK',
    requiredPaymentDetails: bankSchema,
    fee: '8.0',
  ),
  PaymentMethod(
    kind: 'BANK_UNITED BANK FOR AFRICA',
    requiredPaymentDetails: bankSchema,
    fee: '10.0',
  ),
  PaymentMethod(
    kind: 'MOMO_MTN',
    requiredPaymentDetails: momoSchema,
  ),
  PaymentMethod(
    kind: 'MOMO_MPESA',
    requiredPaymentDetails: momoSchema,
  ),
  // PaymentMethod(
  //   kind: 'WALLET_BTC ADDRESS',
  //   requiredPaymentDetails: walletSchema,
  //   fee: '5.0',
  // ),
  // PaymentMethod(
  //   kind: 'WALLET_USDC ADDRESS',
  //   requiredPaymentDetails: walletSchema,
  //   fee: '2.0',
  // ),
];

final paymentMethodProvider = StateProvider<List<PaymentMethod>?>((ref) {
  return _defaultList;
});

const String bankSchema = '''
  {
    "properties": {
      "accountNumber": {
        "type": "string",
        "title": "Account number",
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
        "title": "Phone number",
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
        "title": "Wallet address"
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
