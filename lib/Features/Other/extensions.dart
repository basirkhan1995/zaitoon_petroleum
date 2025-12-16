import 'package:flutter/material.dart';


// Font Scaler based on screen size
extension FontScaler on BuildContext {
  double scaledFont(double multiplier, {double min = 12, double max = 20}) {
    final size = MediaQuery.of(this).size.width * multiplier;
    return size.clamp(min, max);
  }
}

//Get the first letter of a word
extension GetFirstLetterExtension on String {
  /// Returns the first letter(s) of a name:
  /// - If 1 or 2 words: returns first letter of each.
  /// - If 3+ words: returns first letter of first and last words.
  String get getFirstLetter {
    final words = split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .toList();

    if (words.isEmpty) return '';

    if (words.length == 1) {
      return words.first[0];
    } else if (words.length == 2) {
      return '${words[0][0]} ${words[1][0]}';
    } else {
      return '${words.first[0]} ${words.last[0]}';
    }
  }
}

// Open Features/Other/extensions.dart
// If firstWhereOrNull doesn't exist, add it:
extension ListExtensions<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

//Amount Formats
extension NumberFormatting on Object {
  /// Converts string or number to double
  double toDoubleAmount() {
    if (this is num) return (this as num).toDouble();
    if (this is String) {
      final clean = (this as String).replaceAll(',', '').replaceAll(' ', '');
      return double.tryParse(clean) ?? 0;
    }
    return 0;
  }

  /// Formats number with commas and 2 decimals by default
  String toAmount({int fractionDigits = 2}) {
    final numValue = toDoubleAmount();
    final fixed = numValue.toStringAsFixed(fractionDigits);
    return fixed.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
    );
  }
}

extension AmountCleaner on String {
  String get cleanAmount => replaceAll(RegExp(r'[^\d.]'), '');
}

extension CurrencyRateFormatter on Object? {
  String toExchangeRate() {
    double rate;

    // Parse input to double
    if (this is String) {
      rate = double.tryParse(this as String) ?? 0.00;
    } else if (this is num) {
      rate = (this as num).toDouble();
    } else {
      return ""; // Return empty string for unsupported types
    }

    // Format with up to 8 decimal places
    final formatted = rate.toStringAsFixed(8);

    // Trim trailing zeros and optional decimal point
    final trimmed = formatted.replaceAll(RegExp(r'(\.?0+)$'), '');

    // If we removed all decimals, add .0 to indicate it's a rate
    return trimmed.contains('.') ? trimmed : '$trimmed.0';
  }
}