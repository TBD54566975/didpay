import 'package:didpay/shared/utils/text_input_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TextInputUtil', () {
    test('should give phone keyboard type', () {
      const pattern = r'^\+2547[0-9]{8}$';

      expect(TextInputUtil.getKeyboardType(pattern), TextInputType.phone);
    });

    test('should give text keyboard type', () {
      const pattern = '[a-zA-Z]';

      expect(TextInputUtil.getKeyboardType(null), TextInputType.text);
      expect(TextInputUtil.getKeyboardType(pattern), TextInputType.text);
    });

    test('should give US phone number mask', () {
      const pattern = r'^\+1[0-9]{10}$';
      final formatter = TextInputUtil.getMaskFormatter(pattern);

      expect(formatter.getMask(), '+1XXXXXXXXXX');
    });

    test('should give Mexico phone number mask', () {
      const pattern = r'^\+52[0-9]{10}$';
      final formatter = TextInputUtil.getMaskFormatter(pattern);

      expect(formatter.getMask(), '+52XXXXXXXXXX');
    });

    test('should give Ghana phone number mask', () {
      const pattern = r'^\+233[0-9]{9}$';
      final formatter = TextInputUtil.getMaskFormatter(pattern);

      expect(formatter.getMask(), '+233XXXXXXXXX');
    });

    test('should give Kenya phone number mask', () {
      const pattern = r'^\+2547[0-9]{8}$';
      final formatter = TextInputUtil.getMaskFormatter(pattern);

      expect(formatter.getMask(), '+2547XXXXXXXX');
    });

    test('should give 10 digit mask', () {
      const pattern = r'^[0-9]{10}$';
      final formatter = TextInputUtil.getMaskFormatter(pattern);

      expect(formatter.getMask(), 'XXXXXXXXXX');
    });

    test('should give no mask', () {
      const pattern = '[a-zA-Z]';
      final formatter1 = TextInputUtil.getMaskFormatter(pattern);
      final formatter2 = TextInputUtil.getMaskFormatter(null);

      expect(formatter1.getMask(), null);
      expect(formatter2.getMask(), null);
    });

    test('should format only numeric text', () {
      expect(
        TextInputUtil.formatNumericText('+254 712 345678'),
        '+254712345678',
      );
      expect(
        TextInputUtil.formatNumericText('do not remove whitespaces'),
        'do not remove whitespaces',
      );
    });
  });
}
