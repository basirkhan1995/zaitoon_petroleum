import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Date/shamsi_converter.dart';
import 'package:shamsi_date/shamsi_date.dart';

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

//Amount Formats
extension NumberFormatting on String {
  /// Converts string with commas to double
  double toDoubleAmount() {
    final clean = replaceAll(',', '').replaceAll(' ', '');
    return double.tryParse(clean) ?? 0;
  }

  /// Formats number with commas
  String toAmount({int fractionDigits = 0}) {
    final numValue = double.tryParse(replaceAll(',', '').replaceAll(' ', '')) ?? 0;
    return numValue.toStringAsFixed(fractionDigits).replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
    );
  }
}

extension DateTimeExtensions on dynamic {
  /// Returns a DateTime object if input is String, otherwise returns the DateTime as-is
  DateTime? get _dateTime {
    if (this is DateTime) return this as DateTime;
    if (this is String) {
      try {
        return DateTime.tryParse(this as String);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Formats the date as `YYYY-MM-DD`
  String toFormattedDate() {
    final date = _dateTime;
    return date != null
        ? "${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}"
        : "";
  }
}

extension DateTimeFormatExtensions on DateTime {
  /// Returns date in 'yyyy-MM-dd' format (e.g., 2025-10-31)
  String get toDateString => DateFormat('yyyy-MM-dd').format(this);

  /// Returns time in 'HH:mm:ss' format (e.g., 22:29:00)
  String get toTimeString => DateFormat('HH:mm:ss').format(this);

  /// Returns full date-time in 'yyyy-MM-dd HH:mm:ss' format
  String get toFullDateTime => DateFormat('yyyy-MM-dd HH:mm:ss').format(this);

  /// Returns localized readable format (e.g., Friday, Oct 31, 2025 – 10:29 PM)
  String get toReadable => DateFormat('EEEE, MMM d, yyyy – h:mm a').format(this);
}

extension AfghanShamsiDateConverter on DateTime {
  /// Convert to Afghan Shamsi (Jalali) date
  Jalali get toAfghanShamsi => AfghanShamsiConverter.toJalali(this);

  /// Format as compact Afghan date with Persian numbers (e.g., "۱۴۰۲/۵/۱۵")
  String get shamsiDateString => AfghanShamsiConverter.formatCompact(toAfghanShamsi);

  /// Full Afghan date format with Persian numbers (e.g., "دوشنبه، ۱۵ حمل ۱۴۰۲")
  String get shamsiFullDate => AfghanShamsiConverter.formatFull(toAfghanShamsi);

  /// Format with leading zeros and Persian numbers (e.g., "۱۴۰۲/۰۵/۱۵")
  String get shamsiDateFormatted => AfghanShamsiConverter.formatWithLeadingZeros(toAfghanShamsi);

  /// Get current Afghan month name
  String get shamsiMonthName => AfghanShamsiConverter.shamsiMonths[toAfghanShamsi.month] ?? '';

  /// Get current Afghan weekday name
  String get shamsiWeekdayName => AfghanShamsiConverter.shamsiWeekdays[toAfghanShamsi.weekDay] ?? '';
}
