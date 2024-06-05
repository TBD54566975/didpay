class NumberValidationUtil {
  static bool isValidInput(String current, String key, {String? currency}) {
    if (current.contains('.') && key == '.') {
      return false;
    }
    if (current == '0' && key == '0') {
      return false;
    }
    if (num.parse(current + key) > 99999.99) {
      return false;
    }
    if (current.contains('.') &&
        current.split('.').lastOrNull?.length == (currency == 'BTC' ? 8 : 2)) {
      return false;
    }
    return true;
  }

  static bool isInvalidInput(String current, String key, {String? currency}) {
    return !isValidInput(current, key, currency: currency);
  }

  static bool isValidDelete(String current) {
    return current != '0';
  }

  static bool isInvalidDelete(String current) {
    return !isValidDelete(current);
  }
}
