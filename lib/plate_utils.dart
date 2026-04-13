import 'package:flutter/services.dart';

class TunisianPlateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;
    
    // 1. Convert Arabic-Indic digits to Western Arabic digits
    final arabicToWestern = {
      '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
      '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
    };
    arabicToWestern.forEach((arabic, western) {
      text = text.replaceAll(arabic, western);
    });

    // 2. Extract digits and letters
    String clean = text.replaceAll(RegExp(r'[^0-9a-zA-Z]'), '').toUpperCase();
    
    // Find the first letter index
    int letterIdx = -1;
    for (int i = 0; i < clean.length; i++) {
      if (RegExp(r'[A-Z]').hasMatch(clean[i])) {
        letterIdx = i;
        break;
      }
    }

    String p1 = '';
    String p2 = '';
    bool forceTU = false;

    if (letterIdx != -1) {
      // User typed letters (presumably TU or TUN)
      p1 = clean.substring(0, letterIdx).replaceAll(RegExp(r'[^0-9]'), '');
      String rest = clean.substring(letterIdx);
      if (rest.startsWith('TUN')) {
        rest = rest.substring(3);
      } else if (rest.startsWith('TU')) {
        rest = rest.substring(2);
      }
      p2 = rest.replaceAll(RegExp(r'[^0-9]'), '');
      forceTU = true;
    } else {
      // Only numbers typed so far
      if (clean.length > 3) {
        p1 = clean.substring(0, 3);
        p2 = clean.substring(3);
        forceTU = true;
      } else {
        p1 = clean;
      }
    }

    // Constraints: p1 (2-3 chars), p2 (2-4 chars)
    if (p1.length > 3) p1 = p1.substring(0, 3);
    if (p2.length > 4) p2 = p2.substring(0, 4);

    String result = p1;
    if (forceTU || p1.length == 3) {
      if (p1.length >= 2) {
        result += ' TU ';
        result += p2;
      }
    }

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

class TunisianPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    // Convert Arabic-Indic digits if any
    final arabicToWestern = {
      '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
      '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
    };
    arabicToWestern.forEach((arabic, western) {
      text = text.replaceAll(arabic, western);
    });

    // Extract digits only
    String digits = text.replaceAll(RegExp(r'[^0-9]'), '');

    // Handle the case where user types +216 or 216 explicitly
    if (digits.startsWith('216')) {
      digits = digits.substring(3);
    }

    // Limit digits to 8
    if (digits.length > 8) {
      digits = digits.substring(0, 8);
    }

    String result = '+216 ';
    
    // Pattern: XX XXX XXX
    for (int i = 0; i < digits.length; i++) {
       if (i == 2) result += ' ';
       if (i == 5) result += ' ';
       result += digits[i];
    }

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
