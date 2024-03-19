import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class TextInputUtil {
  static const Map<String, String> _countryCodeToMask = {
    '+1': '+1 (XXX) XXX-XXXX',
    '+52': '+52 XX XXXX-XXXX',
    '+233': '+233 2XX XXXXXX',
    '+254': '+254 7XX XXXXXX',
  };

  static MaskTextInputFormatter getMaskFormatter(String? pattern) {
    return MaskTextInputFormatter(
      mask: _createMask(pattern),
      filter: {
        'X': RegExp('[0-9]'),
      },
    );
  }

  static TextInputType getKeyboardType(String? pattern) {
    return pattern?.contains(RegExp('[a-zA-Z]')) ?? true
        ? TextInputType.text
        : TextInputType.phone;
  }

  static String formatNumericText(String text) {
    return text.contains(RegExp('[a-zA-Z]')) ? text : text.replaceAll(' ', '');
  }

  static String? _createMask(String? pattern) {
    if (pattern == null) return null;

    final countryCode = _getCountryCode(pattern);
    if (countryCode != null && _countryCodeToMask.containsKey(countryCode)) {
      return _countryCodeToMask[countryCode];
    }

    final match = RegExp(r'\[0-9]\{(\d+)\}').firstMatch(pattern);
    return match != null
        ? List.filled(int.parse(match.group(1) ?? '0'), 'X').join()
        : null;
  }

  static String? _getCountryCode(String? pattern) {
    if (pattern == null) return null;
    return RegExp(r'\+(\d{1,3})').firstMatch(pattern)?.group(0);
  }
}
