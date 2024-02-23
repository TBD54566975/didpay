import 'package:didpay/shared/utils/number_validation_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NumberValidationUtil', () {
    group('validateInput', () {
      test('invalidate if input is 0 and user attempts to input 0', () {
        final validateKeyPress = NumberValidationUtil.isValidInput('0', '0');

        expect(validateKeyPress, false);
      });

      test('invalidate if input has decimal and user attempts another decimal',
          () {
        final validateKeyPress = NumberValidationUtil.isValidInput('0.1', '.');

        expect(validateKeyPress, false);
      });

      test(
          'invalidate if input has two decimal places and user attempts another decimal',
          () {
        final validateKeyPress = NumberValidationUtil.isValidInput('0.10', '.');

        expect(validateKeyPress, false);
      });

      test('invalidate if user attempts to enter value > 99999.99', () {
        final validateKeyPress =
            NumberValidationUtil.isValidInput('12345', '6');

        expect(validateKeyPress, false);
      });

      test('validate if user enters a safe currency value', () {
        final validateKeyPress =
            NumberValidationUtil.isValidInput('999.9', '9');

        expect(validateKeyPress, true);
      });
    });

    group('validateDelete', () {
      test('invalidate if input is 0 and user attempts to backspace', () {
        final validateKeyPress = NumberValidationUtil.isValidDelete('0');

        expect(validateKeyPress, false);
      });

      test('validate if input is > 0 and user attempts to backspace', () {
        final validateKeyPress = NumberValidationUtil.isValidDelete('12345');

        expect(validateKeyPress, true);
      });
    });
  });
}
