import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class TextInputUtil {
  static MaskTextInputFormatter getMaskFormatter(String? pattern) {
    return MaskTextInputFormatter(
      mask: _regexToMask(pattern),
      filter: {'X': RegExp('[0-9]')},
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

  static String? _regexToMask(String? regex) {
    if (regex == null) return null;

    final mask = StringBuffer();

    for (var i = 0; i < regex.length; i++) {
      if (RegExp(r'\d').hasMatch(regex[i])) {
        mask.write(regex[i]);
      } else if (regex[i] == '[') {
        i = regex.indexOf(']', i);
      } else if (regex[i] == '{') {
        final numEnd = regex.indexOf('}', i);
        final num = int.parse(regex.substring(i + 1, numEnd));
        mask.write('X' * num);
        i = numEnd;
      }
    }

    final maskString = mask.toString();
    return maskString.contains(RegExp(r'\d'))
        ? '+$maskString'
        : maskString.isNotEmpty
            ? maskString
            : null;
  }
}
