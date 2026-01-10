

import 'dart:convert';

List<DailyGrossModel> dailyGrossModelFromMap(String str) => List<DailyGrossModel>.from(json.decode(str).map((x) => DailyGrossModel.fromMap(x)));

String dailyGrossModelToMap(List<DailyGrossModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class DailyGrossModel {
  final DateTime? dates;
  final String? category;
  final String? balance;

  DailyGrossModel({
    this.dates,
    this.category,
    this.balance,
  });

  DailyGrossModel copyWith({
    DateTime? dates,
    String? category,
    String? balance,
  }) =>
      DailyGrossModel(
        dates: dates ?? this.dates,
        category: category ?? this.category,
        balance: balance ?? this.balance,
      );

  factory DailyGrossModel.fromMap(Map<String, dynamic> json) => DailyGrossModel(
    dates: json["dates"] == null ? null : DateTime.parse(json["dates"]),
    category: json["category"],
    balance: json["balance"],
  );

  Map<String, dynamic> toMap() => {
    "dates": "${dates!.year.toString().padLeft(4, '0')}-${dates!.month.toString().padLeft(2, '0')}-${dates!.day.toString().padLeft(2, '0')}",
    "category": category,
    "balance": balance,
  };
}
