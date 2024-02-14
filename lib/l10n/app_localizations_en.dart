import 'app_localizations.dart';

/// The translations for English (`en`).
class LocEn extends Loc {
  LocEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'DIDPay';

  @override
  String get welcomeToDIDPay => 'Welcome to DIDPay';

  @override
  String get getStarted => 'Get started';

  @override
  String get toSendMoney => 'To send money, you\'ll need to verify your identity with a PFI in your region';

  @override
  String get selectYourRegion => 'Select your region';

  @override
  String get home => 'Home';

  @override
  String get done => 'Done';

  @override
  String get deposit => 'Deposit';

  @override
  String get send => 'Send';

  @override
  String get to => 'To:';

  @override
  String get pay => 'Pay';

  @override
  String get scanQrCode => 'Don\'t know the recipient\'s DID? Scan their QR code';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get next => 'Next';

  @override
  String get accountBalance => 'Account balance';

  @override
  String get youDeposit => 'You deposit';

  @override
  String get youWithdraw => 'You withdraw';

  @override
  String get youGet => 'You get';

  @override
  String get estRate => 'Est. rate';

  @override
  String get serviceFee => 'Service fee';

  @override
  String get usd => 'USD';

  @override
  String get activity => 'Activity';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get startByAdding => 'Start by adding funds to your account!';

  @override
  String get transactionDetails => 'Transaction details';

  @override
  String get youPay => 'You pay';

  @override
  String get youPaid => 'You paid';

  @override
  String get youReceived => 'You received';

  @override
  String txnTypeQuote(String txnType) {
    return '$txnType quote';
  }

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get yourRequestWasSent => 'Your request was sent!';

  @override
  String get yourPaymentWasSent => 'Your payment was sent!';

  @override
  String get verificationComplete => 'Verification complete!';

  @override
  String get makeSureInfoIsCorrect => 'Make sure this information is correct.';

  @override
  String enterYourPaymentChannelDetails(String paymentChannel) {
    return 'Enter your $paymentChannel details';
  }

  @override
  String serviceFeeAmount(String amount, String currency) {
    return 'Service fee: $amount $currency';
  }

  @override
  String get search => 'Search';

  @override
  String get serviceFeesMayApply => 'Service fees may apply';

  @override
  String get selectPaymentMethod => 'Select a payment method';

  @override
  String get didPrefix => 'did:...';

  @override
  String get thisFieldCannotBeEmpty => 'This field cannot be empty';

  @override
  String get invalidDid => 'Invalid DID';

  @override
  String get noDidQrCodeFound => 'No DID QR Code found';

  @override
  String get myDid => 'My DID';

  @override
  String get copiedDid => 'Copied DID!';

  @override
  String get simulatedQrCodeScan => 'Simulated QR code scan!';

  @override
  String get sendingPayment => 'Sending payment...';

  @override
  String get verifyingYourIdentity => 'Verifying your identity...';
}
