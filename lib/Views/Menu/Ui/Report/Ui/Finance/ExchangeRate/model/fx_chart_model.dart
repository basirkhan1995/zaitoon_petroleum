import 'package:intl/intl.dart';

/// =======================
/// API MODEL
/// =======================
class FxExchangeRateChartModel {
  final DateTime date;
  final String fromCode;
  final String toCode;
  final double crExchange;
  final double avgRate;

  FxExchangeRateChartModel({
    required this.date,
    required this.fromCode,
    required this.toCode,
    required this.crExchange,
    required this.avgRate,
  });

  factory FxExchangeRateChartModel.fromJson(Map<String, dynamic> json) {
    return FxExchangeRateChartModel(
      date: DateTime.parse(json['rate_date']),
      fromCode: json['from_code'],
      toCode: json['to_code'],
      crExchange: double.tryParse(json['crExchange']) ?? 0,
      avgRate: double.tryParse(json['avg_rate']) ?? 0,
    );
  }
}

/// =======================
/// CHART DATA MODEL
/// =======================
class ExchangeRateChartData {
  final DateTime date;
  final double value;

  ExchangeRateChartData({
    required this.date,
    required this.value,
  });
}

/// =======================
/// ENUMS
/// =======================
enum RateValueType {
  exchange,
  average,
}

/// =======================
/// CHART DATA PREPARATION
/// =======================
List<ExchangeRateChartData> prepareExchangeRateChartData(
    List<FxExchangeRateChartModel> data, {
      required String fromCode,
      required String toCode,
      RateValueType valueType = RateValueType.exchange,
    }) {
  final map = <DateTime, double>{};

  for (final item in data) {
    if (item.fromCode != fromCode || item.toCode != toCode) continue;

    final date = DateTime(item.date.year, item.date.month, item.date.day);

    map[date] = valueType == RateValueType.exchange
        ? item.crExchange
        : item.avgRate;
  }

  final list = map.entries
      .map((e) => ExchangeRateChartData(date: e.key, value: e.value))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  return list;
}

/// =======================
/// HELPER
/// =======================
String formatCurrencyPair(String from, String to) => '$from → $to';

String formatChartDate(DateTime date) =>
    DateFormat('MM/dd').format(date);
