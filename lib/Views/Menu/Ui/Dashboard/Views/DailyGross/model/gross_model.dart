import 'dart:convert';

List<DailyGrossModel> dailyGrossModelFromMap(String str) =>
    List<DailyGrossModel>.from(
      json.decode(str).map((x) => DailyGrossModel.fromMap(x)),
    );

class DailyGrossModel {
  final DateTime date;
  final GrossCategory category;
  final double balance;

  const DailyGrossModel({
    required this.date,
    required this.category,
    required this.balance,
  });

  factory DailyGrossModel.fromMap(Map<String, dynamic> json) {
    return DailyGrossModel(
      date: DateTime.parse(json['dates']),
      category: GrossCategoryX.fromString(json['category']),
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,
    );
  }
}

/// Strongly typed category (no string comparison bugs)
enum GrossCategory { profit, loss }

extension GrossCategoryX on GrossCategory {
  static GrossCategory fromString(String? value) {
    if (value == null) return GrossCategory.loss;

    switch (value.toLowerCase()) {
      case 'proffit': // API typo
      case 'profit':
        return GrossCategory.profit;
      default:
        return GrossCategory.loss;
    }
  }
}
