import 'package:didpay/shared/http_status.dart';

// TODO(ethan-tbd): finish working on custom exceptions
class TbdexException implements Exception {
  final String message;
  final int errorCode;

  TbdexException(this.message, this.errorCode);

  @override
  String toString() {
    return '${errorCode.category}: $errorCode, $message';
  }
}

class RfqException extends TbdexException {
  RfqException(super.message, super.errorCode);
}

class OfferingException extends TbdexException {
  OfferingException(super.message, super.errorCode);
}

class QuoteException extends TbdexException {
  QuoteException(super.message, super.errorCode);
}
