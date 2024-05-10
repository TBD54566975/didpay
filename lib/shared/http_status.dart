enum HttpStatus {
  informational,
  success,
  redirection,
  clientError,
  serverError,
  unknown;

  @override
  String toString() => name.substring(0, 1).toUpperCase() + name.substring(1);
}

extension HttpStatusExtension on int {
  HttpStatus get category {
    if (this >= 100 && this < 200) {
      return HttpStatus.informational;
    } else if (this >= 200 && this < 300) {
      return HttpStatus.success;
    } else if (this >= 300 && this < 400) {
      return HttpStatus.redirection;
    } else if (this >= 400 && this < 500) {
      return HttpStatus.clientError;
    } else if (this >= 500 && this < 600) {
      return HttpStatus.serverError;
    } else {
      return HttpStatus.unknown;
    }
  }
}
