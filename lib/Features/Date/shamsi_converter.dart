import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

class AfghanShamsiConverter {

  // Add this to your AfghanShamsiConverter class
  static String formatJalali(Jalali jalali, {String format = 'yyyy/mm/dd'}) {
    final month = jalali.month.toString().padLeft(2, '0');
    final day = jalali.day.toString().padLeft(2, '0');

    return format
        .replaceAll('yyyy', jalali.year.toString())
        .replaceAll('mm', month)
        .replaceAll('m', jalali.month.toString())
        .replaceAll('dd', day)
        .replaceAll('d', jalali.day.toString());
  }

  /// Convert various input types to Jalali date
  static Jalali toJalali(dynamic input) {
    if (input is DateTime) {
      return Jalali.fromDateTime(input);
    } else if (input is String) {
      // Try parsing different string formats
      final dateTime = DateTime.tryParse(input);
      if (dateTime != null) {
        return Jalali.fromDateTime(dateTime);
      }

      // Handle custom string formats if needed
      // Example: "1402/5/15" or "1402-05-15"
      final parts = input.split(RegExp(r'[/-]'));
      if (parts.length == 3) {
        final year = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final day = int.tryParse(parts[2]);
        if (year != null && month != null && day != null) {
          return Jalali(year, month, day);
        }
      }
    }

    throw ArgumentError('Unsupported input type for Afghan Shamsi conversion');
  }

  /// Afghan month names in Dari
  static const Map<int, String> shamsiMonths = {
    1: 'حمل',   // Hamal (Farvardin)
    2: 'ثور',   // Sawr (Ordibehesht)
    3: 'جوزا',  // Jawza (Khordad)
    4: 'سرطان', // Saratan (Tir)
    5: 'اسد',   // Asad (Mordad)
    6: 'سنبله', // Sonbola (Shahrivar)
    7: 'میزان', // Mizan (Mehr)
    8: 'عقرب',  // Aqrab (Aban)
    9: 'قوس',   // Qaws (Azar)
    10: 'جدی',  // Jadi (Dey)
    11: 'دلو',  // Dalwa (Bahman)
    12: 'حوت',  // Hut (Esfand)
  };

  /// Afghan weekday names in Dari
  static const Map<int, String> shamsiWeekdays = {
    1: 'شنبه',   // Saturday
    2: 'یکشنبه',  // Sunday
    3: 'دوشنبه', // Monday
    4: 'سه‌شنبه',  // Tuesday
    5: 'چهارشنبه',     // Wednesday
    6: 'پنجشنبه',     // Thursday
    7: 'جمعه',   // Friday
  };

  /// Helper function to convert English digits to Persian
  static String toPersianNumbers(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], farsi[i]);
    }
    return input;
  }

  /// Format Jalali date as compact string
  static String formatCompact(Jalali j) {
    return toPersianNumbers('${j.year}/${j.month}/${j.day}');
  }

  /// Format Jalali date as full string
  static String formatFull(Jalali j) {
    return '${shamsiWeekdays[j.weekDay]}، ${toPersianNumbers('${j.day}')} ${shamsiMonths[j.month]} ${toPersianNumbers('${j.year}')}';
  }

  /// Format Jalali date with leading zeros
  static String formatWithLeadingZeros(Jalali j) {
    return toPersianNumbers('${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}');
  }
}

extension JalaliToGregorian on Jalali {
  /// Convert Jalali date to Gregorian DateTime
  DateTime toGregorian() {
    return toDateTime();
  }

  /// Convert Jalali date to Gregorian date string (yyyy-mm-dd format)
  String toGregorianString() {
    final dateTime = toDateTime();
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  /// Convert Jalali date to formatted Gregorian date string
  String toFormattedGregorianString({String format = 'yyyy-MM-dd'}) {
    final dateTime = toDateTime();
    return format
        .replaceAll('yyyy', dateTime.year.toString())
        .replaceAll('MM', dateTime.month.toString().padLeft(2, '0'))
        .replaceAll('M', dateTime.month.toString())
        .replaceAll('dd', dateTime.day.toString().padLeft(2, '0'))
        .replaceAll('d', dateTime.day.toString());
  }

  /// Convert Jalali date to localized Gregorian date string
  String toLocalizedGregorianString(BuildContext context) {
    final dateTime = toDateTime();
    return MaterialLocalizations.of(context).formatShortDate(dateTime);
  }
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

extension StringToAfghanShamsi on String {
  /// Convert string to Afghan Shamsi (Jalali) date
  Jalali get toAfghanShamsi => AfghanShamsiConverter.toJalali(this);

  /// Format as compact Afghan date with Persian numbers (e.g., "۱۴۰۲/۵/۱۵")
  String get shamsiDateString => AfghanShamsiConverter.formatCompact(toAfghanShamsi);

  /// Full Afghan date format with Persian numbers (e.g., "دوشنبه، ۱۵ حمل ۱۴۰۲")
  String get shamsiFullDate => AfghanShamsiConverter.formatFull(toAfghanShamsi);

  /// Format with leading zeros and Persian numbers (e.g., "۱۴۰۲/۰۵/۱۵")
  String get shamsiDateFormatted => AfghanShamsiConverter.formatWithLeadingZeros(toAfghanShamsi);

  /// Get month name from date string
  String get shamsiMonthName => AfghanShamsiConverter.shamsiMonths[toAfghanShamsi.month] ?? '';

  /// Get weekday name from date string
  String get shamsiWeekdayName => AfghanShamsiConverter.shamsiWeekdays[toAfghanShamsi.weekDay] ?? '';
}

extension JalaliFormatting on Jalali {
  /// Convert to compact Afghan date string (e.g., "1402/5/15")
  String toShamsiString() {
    return AfghanShamsiConverter.formatJalali(this, format: 'yyyy/m/d');
  }

  /// Convert to formatted Afghan date string with leading zeros (e.g., "1402/05/15")
  String toFormattedShamsiString() {
    return AfghanShamsiConverter.formatJalali(this, format: 'yyyy/mm/dd');
  }

  /// Convert to full Afghan date string (e.g., "دوشنبه، ۱۵ حمل ۱۴۰۲")
  String toFullShamsiString() {
    return AfghanShamsiConverter.formatFull(this);
  }

  /// Convert to Persian numbers string (e.g., "۱۴۰۲/۰۵/۱۵")
  String toPersianShamsiString() {
    return AfghanShamsiConverter.toPersianNumbers(toFormattedShamsiString());
  }
}