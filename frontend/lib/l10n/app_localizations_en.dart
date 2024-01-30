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
}
