class NumberPadInputValidationUtil {
  static bool validateKeyPress(String input, String key) {
    bool isValidKeyPress = true;
    if (input == '0') {
      isValidKeyPress = key != '0';
    }
    if (input.contains('.')) {
      isValidKeyPress = key != '.';
    }
    if (input.contains('.') && input.split('.').last.length == 2) {
      isValidKeyPress = false;
    }
    if (isValidKeyPress && num.parse(input + key) > 99999.99) {
      isValidKeyPress = false;
    }
    return isValidKeyPress;
  }

  static bool validateDeletePress(String input) {
    bool isValidKeyPress = true;
    if (input == '0') {
      isValidKeyPress = false;
    }
    return isValidKeyPress;
  }
}
