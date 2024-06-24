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
  String get interactWithPfis => 'Interact with PFIs (Participating Financial Institutions) and send money to others around the world';

  @override
  String get whereAreYouLocated => 'Where are you located?';

  @override
  String get done => 'Done';

  @override
  String get deposit => 'Deposit';

  @override
  String get send => 'Send';

  @override
  String get to => 'To:';

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
  String get youReceive => 'You receive';

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
  String get yourPaymentWasSent => 'Your payment was sent!';

  @override
  String get verificationComplete => 'Verification complete!';

  @override
  String get makeSureInfoIsCorrect => 'Make sure this information is correct.';

  @override
  String get enterYourPaymentDetails => 'Enter your payment details';

  @override
  String get enterTheirPaymentDetails => 'Enter their payment details';

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
  String get myVc => 'My VC';

  @override
  String get vcNotFound => 'VC not found';

  @override
  String get copiedDid => 'Copied DID!';

  @override
  String get simulatedQrCodeScan => 'Simulated QR code scan!';

  @override
  String get sendingPayment => 'Sending payment...';

  @override
  String get verifyingYourIdentity => 'Verifying your identity...';

  @override
  String get reviewYourPayment => 'Review your payment';

  @override
  String get depositAmount => 'Deposit amount';

  @override
  String get withdrawAmount => 'Withdraw amount';

  @override
  String get total => 'Total';

  @override
  String get submit => 'Submit';

  @override
  String get selectYourCountry => 'Select your country to see what PFIs are available to you';

  @override
  String get getStartedWithAPfi => 'Get started with a PFI';

  @override
  String get selectAPfi => 'Select a PFI to verify your identity and provide you liquidity';

  @override
  String get termsOfService => 'Terms of service';

  @override
  String get exampleTerms => 'Financial services are being provided by Block, Inc. By clicking on the \"next\" button, you consent to opening an account with Block, Inc. Block, Inc. will ask you for personal information to verify your identity before opening an account...';

  @override
  String get iCertifyThatIAgreeToThe => 'I certify that I agree to the ';

  @override
  String get userAgreement => 'User Agreement';

  @override
  String get andIHaveReadThe => ', and I have read the ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String sendAmountUsdc(String amount) {
    return 'Send $amount USDC';
  }

  @override
  String get availableBalance => 'Available balance: ';

  @override
  String get selectWallet => 'Select your wallet';

  @override
  String get selectWalletDescription => 'We recommend you use DidPay with a compatible digital wallet. Select from the following options.';

  @override
  String get error => 'Error';

  @override
  String get selectPaymentType => 'Select a payment type';

  @override
  String get account => 'Account';

  @override
  String get pending => 'Pending';

  @override
  String get failed => 'Failed';

  @override
  String get completed => 'Completed';

  @override
  String get youSend => 'You send';

  @override
  String get theyGet => 'They get';

  @override
  String get sendMoneyAbroad => 'Send money abroad';

  @override
  String get selectCountryToGetStarted => 'Select a country to get started';

  @override
  String get exchangeRate => 'Exchange rate';

  @override
  String txnTypeFee(String txnType) {
    return '$txnType fee';
  }

  @override
  String get requestedAmount => 'Requested amount';

  @override
  String get totalToAccount => 'Total to account';

  @override
  String get totalToYou => 'Total to you';

  @override
  String get totalToRecipient => 'Total to recipient';

  @override
  String get pay => 'Pay';

  @override
  String get errorFound => 'Error found';

  @override
  String get tapToRetry => 'Tap to retry';

  @override
  String get unableToRetrieveTxns => 'Unable to retrieve transactions';

  @override
  String get addAPfi => 'Add a PFI';

  @override
  String get noPfisFound => 'No PFIs found';

  @override
  String get startByAddingAPfi => 'Start by adding a PFI';

  @override
  String get pfiAdded => 'PFI added!';

  @override
  String get addingPfi => 'Adding PFI...';

  @override
  String get mustAddPfiBeforeSending => 'Must add a PFI before sending funds!';

  @override
  String get gettingYourQuote => 'Getting your quote...';

  @override
  String get sendingYourRequest => 'Sending your request...';

  @override
  String get confirmingYourOrder => 'Confirming your order...';

  @override
  String get orderConfirmed => 'Order confirmed!';

  @override
  String get removePfi => 'Remove PFI';

  @override
  String get cancel => 'Cancel';

  @override
  String get linkedPfis => 'Linked PFIs';

  @override
  String get noTransactionsFound => 'No transactions found';

  @override
  String get enterRecipientDap => 'Enter the recipient\'s DAP';

  @override
  String get fetchingOfferings => 'Fetching offerings...';

  @override
  String get startingIdv => 'Starting identity verification...';

  @override
  String get identityVerificationComplete => 'Identity verification complete!';

  @override
  String get issuedCredentials => 'Issued credentials';

  @override
  String get removeCredential => 'Remove credential';

  @override
  String get noCredentialsIssuedYet => 'No credentials issued yet';

  @override
  String get selectCurrency => 'Select currency';

  @override
  String get add => 'Add';

  @override
  String get fetchingTransactions => 'Fetching transactions...';

  @override
  String get scan => 'Scan';

  @override
  String get cameraUnavailable => 'Camera unavailable';

  @override
  String get dontKnowTheirDap => 'Don\'t know their DAP? Scan their QR code instead';

  @override
  String get featureFlags => 'Feature flags';

  @override
  String get lucidMode => 'Lucid mode';

  @override
  String get selectFromUnfilteredList => 'Select from an unfiltered list of all your PFI offerings.';

  @override
  String get exit => 'Exit';

  @override
  String get stay => 'Stay';

  @override
  String stoptxnType(String txnType) {
    return 'Stop ${txnType}ing money?';
  }

  @override
  String get ifYouExitNow => 'If you exit now, you\'ll lose all your progress';
}
