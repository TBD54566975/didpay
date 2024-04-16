import 'package:hooks_riverpod/hooks_riverpod.dart';

// TODO(ethan-tbd): remove this file when tbdex is in
class PaymentMethod {
  final String kind;
  final String name;
  final String requiredPaymentDetails;
  final String? group;
  final String? fee;

  PaymentMethod({
    required this.kind,
    required this.name,
    required this.requiredPaymentDetails,
    this.group,
    this.fee,
  });
}

final _defaultList = [
  PaymentMethod(
    kind: 'AB',
    name: 'Access Bank',
    requiredPaymentDetails: bankSchema,
    group: 'Bank',
    fee: '9',
  ),
  PaymentMethod(
    kind: 'GTB',
    name: 'GT Bank',
    requiredPaymentDetails: bankSchema,
    group: 'Bank',
    fee: '8',
  ),
  PaymentMethod(
    kind: 'UBFA',
    name: 'United Bank for Africa',
    requiredPaymentDetails: bankSchema,
    group: 'Bank',
    fee: '10',
  ),
  PaymentMethod(
    kind: 'MTN',
    name: 'MTN',
    requiredPaymentDetails: momoSchema,
    group: 'Mobile money',
  ),
  PaymentMethod(
    kind: 'MPESA',
    name: 'M-Pesa',
    requiredPaymentDetails: momoSchema,
    group: 'Mobile money',
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

const String bankSchema = r'''
  {
    "properties": {
      "accountNumber": {
        "type": "string",
        "title": "Account number",
        "description": "Bank account number of the recipient",
        "minLength": 10,
        "maxLength": 10,
        "pattern": "^[0-9]{10}$"
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

const String momoSchema = r'''
  {
    "properties": {
      "accountNumber": {
        "type": "string",
        "title": "Phone number",
        "description": "Mobile money account number of the recipient",
        "minLength": 13,
        "maxLength": 13,
        "pattern": "^\\+2547[0-9]{8}$"
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
