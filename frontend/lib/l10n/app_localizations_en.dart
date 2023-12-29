import 'app_localizations.dart';

/// The translations for English (`en`).
class LocEn extends Loc {
  LocEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'DIDPay';

  @override
  String get welcome => 'Welcome';

  @override
  String get getStarted => 'Get started';

  @override
  String get toSendMoney => 'To send money, we need to quickly verify your identity';

  @override
  String get congratsOnYourDid => 'Congrats on your new DID!';

  @override
  String get verifyIdentity => 'Verify your identity';
}
