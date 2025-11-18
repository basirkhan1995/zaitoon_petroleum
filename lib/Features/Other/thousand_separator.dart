import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class SmartThousandsDecimalFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat("#,##0");

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String raw = newValue.text.replaceAll(',', '');

    // If empty or just a dot
    if (raw.isEmpty || raw == '.') return newValue;

    // Match valid decimal number (0 to 4 digits after dot)
    final valid = RegExp(r'^\d*\.?\d{0,4}$');
    if (!valid.hasMatch(raw)) return oldValue;

    final parts = raw.split('.');
    final intPartRaw = parts[0];
    final decPart = parts.length > 1 ? parts[1] : null;

    String formattedInt = '';
    if (intPartRaw.isNotEmpty) {
      try {
        formattedInt = _formatter.format(int.parse(intPartRaw));
      } catch (e) {
        return oldValue;
      }
    }

    // Build final text
    String newText = decPart != null
        ? '$formattedInt.$decPart'
        : formattedInt;

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
