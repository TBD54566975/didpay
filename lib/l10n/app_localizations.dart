import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

/// Callers can lookup localized strings with an instance of Loc
/// returned by `Loc.of(context)`.
///
/// Applications need to include `Loc.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: Loc.localizationsDelegates,
///   supportedLocales: Loc.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the Loc.supportedLocales
/// property.
abstract class Loc {
  Loc(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static Loc of(BuildContext context) {
    return Localizations.of<Loc>(context, Loc)!;
  }

  static const LocalizationsDelegate<Loc> delegate = _LocDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'DIDPay'**
  String get appName;

  /// No description provided for @welcomeToDIDPay.
  ///
  /// In en, this message translates to:
  /// **'Welcome to DIDPay'**
  String get welcomeToDIDPay;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @toSendMoney.
  ///
  /// In en, this message translates to:
  /// **'To send money, you\'ll need to verify your identity with a PFI in your region'**
  String get toSendMoney;

  /// No description provided for @selectYourRegion.
  ///
  /// In en, this message translates to:
  /// **'Select your region'**
  String get selectYourRegion;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To:'**
  String get to;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// No description provided for @scanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Don\'t know the recipient\'s DID? Scan their QR code'**
  String get scanQrCode;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @accountBalance.
  ///
  /// In en, this message translates to:
  /// **'Account balance'**
  String get accountBalance;

  /// No description provided for @youDeposit.
  ///
  /// In en, this message translates to:
  /// **'You deposit'**
  String get youDeposit;

  /// No description provided for @youWithdraw.
  ///
  /// In en, this message translates to:
  /// **'You withdraw'**
  String get youWithdraw;

  /// No description provided for @youGet.
  ///
  /// In en, this message translates to:
  /// **'You get'**
  String get youGet;

  /// No description provided for @estRate.
  ///
  /// In en, this message translates to:
  /// **'Est. rate'**
  String get estRate;

  /// No description provided for @serviceFee.
  ///
  /// In en, this message translates to:
  /// **'Service fee'**
  String get serviceFee;

  /// No description provided for @usd.
  ///
  /// In en, this message translates to:
  /// **'USD'**
  String get usd;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @startByAdding.
  ///
  /// In en, this message translates to:
  /// **'Start by adding funds to your account!'**
  String get startByAdding;

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction details'**
  String get transactionDetails;

  /// No description provided for @youPay.
  ///
  /// In en, this message translates to:
  /// **'You pay'**
  String get youPay;

  /// No description provided for @youPaid.
  ///
  /// In en, this message translates to:
  /// **'You paid'**
  String get youPaid;

  /// No description provided for @youReceived.
  ///
  /// In en, this message translates to:
  /// **'You received'**
  String get youReceived;

  /// No description provided for @txnTypeQuote.
  ///
  /// In en, this message translates to:
  /// **'{txnType} quote'**
  String txnTypeQuote(String txnType);

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @yourRequestWasSent.
  ///
  /// In en, this message translates to:
  /// **'Your request was sent!'**
  String get yourRequestWasSent;

  /// No description provided for @yourPaymentWasSent.
  ///
  /// In en, this message translates to:
  /// **'Your payment was sent!'**
  String get yourPaymentWasSent;

  /// No description provided for @verificationComplete.
  ///
  /// In en, this message translates to:
  /// **'Verification complete!'**
  String get verificationComplete;

  /// No description provided for @makeSureInfoIsCorrect.
  ///
  /// In en, this message translates to:
  /// **'Make sure this information is correct.'**
  String get makeSureInfoIsCorrect;

  /// No description provided for @enterYourPaymentChannelDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter your {paymentChannel} details'**
  String enterYourPaymentChannelDetails(String paymentChannel);

  /// No description provided for @serviceFeeAmount.
  ///
  /// In en, this message translates to:
  /// **'Service fee: {amount} {currency}'**
  String serviceFeeAmount(String amount, String currency);

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @serviceFeesMayApply.
  ///
  /// In en, this message translates to:
  /// **'Service fees may apply'**
  String get serviceFeesMayApply;

  /// No description provided for @selectPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Select a payment method'**
  String get selectPaymentMethod;

  /// No description provided for @didPrefix.
  ///
  /// In en, this message translates to:
  /// **'did:...'**
  String get didPrefix;

  /// No description provided for @thisFieldCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'This field cannot be empty'**
  String get thisFieldCannotBeEmpty;

  /// No description provided for @invalidDid.
  ///
  /// In en, this message translates to:
  /// **'Invalid DID'**
  String get invalidDid;

  /// No description provided for @noDidQrCodeFound.
  ///
  /// In en, this message translates to:
  /// **'No DID QR Code found'**
  String get noDidQrCodeFound;

  /// No description provided for @myDid.
  ///
  /// In en, this message translates to:
  /// **'My DID'**
  String get myDid;

  /// No description provided for @copiedDid.
  ///
  /// In en, this message translates to:
  /// **'Copied DID!'**
  String get copiedDid;

  /// No description provided for @simulatedQrCodeScan.
  ///
  /// In en, this message translates to:
  /// **'Simulated QR code scan!'**
  String get simulatedQrCodeScan;
}

class _LocDelegate extends LocalizationsDelegate<Loc> {
  const _LocDelegate();

  @override
  Future<Loc> load(Locale locale) {
    return SynchronousFuture<Loc>(lookupLoc(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_LocDelegate old) => false;
}

Loc lookupLoc(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return LocEn();
  }

  throw FlutterError(
    'Loc.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
