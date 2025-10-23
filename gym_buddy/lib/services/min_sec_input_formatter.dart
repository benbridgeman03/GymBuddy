import 'package:flutter/services.dart';

class MinSecInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digits
    String digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) return const TextEditingValue(text: '');

    // Limit to max 3 digits (x:xx)
    if (digits.length > 3) digits = digits.substring(0, 3);

    String formatted;
    if (digits.length == 1) {
      formatted = digits; // just minutes
    } else if (digits.length == 2) {
      formatted = '${digits[0]}:${digits[1]}'; // x:x
    } else {
      formatted = '${digits[0]}:${digits.substring(1)}'; // x:xx
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
