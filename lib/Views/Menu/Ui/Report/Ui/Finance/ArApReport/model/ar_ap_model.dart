
import 'dart:convert';
import 'package:intl/intl.dart';
List<ArApModel> arApModelFromMap(String str) =>
    List<ArApModel>.from(
      json.decode(str).map((x) => ArApModel.fromMap(x)),
    );

String arApModelToMap(List<ArApModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class ArApModel {
  final int? perId;
  final String? fullName;
  final String? perPhone;
  final int? accNumber;
  final String? accName;
  final String? accCurrency;
  final int? accStatus;
  final String? accLimit;

  /// IMPORTANT: keep balance as double
  final double? accBalance;

  ArApModel({
    this.perId,
    this.fullName,
    this.perPhone,
    this.accNumber,
    this.accName,
    this.accCurrency,
    this.accStatus,
    this.accLimit,
    this.accBalance,
  });

  /// =========================
  /// JSON
  /// =========================
  factory ArApModel.fromMap(Map<String, dynamic> json) => ArApModel(
    perId: json['perID'],
    fullName: json['fullName'],
    perPhone: json['perPhone'],
    accNumber: json['accNumber'],
    accName: json['accName'],
    accCurrency: json['accCurrency'],
    accStatus: json['accStatus'],
    accLimit: json['accLimit'],
    accBalance: _parseDouble(json['accBalance']),
  );

  Map<String, dynamic> toMap() => {
    'perID': perId,
    'fullName': fullName,
    'perPhone': perPhone,
    'accNumber': accNumber,
    'accName': accName,
    'accCurrency': accCurrency,
    'accStatus': accStatus,
    'accLimit': accLimit,
    'accBalance': accBalance?.toStringAsFixed(4),
  };

  /// =========================
  /// HELPERS (AR / AP LOGIC)
  /// =========================

  double get balance => accBalance ?? 0.0;

  bool get isAR => balance < 0;
  bool get isAP => balance > 0;

  double get absBalance => balance.abs();

  String get formattedBalance =>
      NumberFormat('#,##0.00').format(balance);


  /// =========================
  /// COPY
  /// =========================
  ArApModel copyWith({
    int? perId,
    String? fullName,
    String? perPhone,
    int? accNumber,
    String? accName,
    String? accCurrency,
    int? accStatus,
    String? accLimit,
    double? accBalance,
  }) {
    return ArApModel(
      perId: perId ?? this.perId,
      fullName: fullName ?? this.fullName,
      perPhone: perPhone ?? this.perPhone,
      accNumber: accNumber ?? this.accNumber,
      accName: accName ?? this.accName,
      accCurrency: accCurrency ?? this.accCurrency,
      accStatus: accStatus ?? this.accStatus,
      accLimit: accLimit ?? this.accLimit,
      accBalance: accBalance ?? this.accBalance,
    );
  }

  /// =========================
  /// SAFE PARSER
  /// =========================
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '')) ?? 0.0;
    }
    return 0.0;
  }
  double calculateTotalPayable(List<ArApModel> list) {
    return list
        .where((e) => e.isAP)
        .fold(0.0, (sum, e) => sum + e.balance);
  }

  double calculateTotalReceivable(List<ArApModel> list) {
    return list
        .where((e) => e.isAR)
        .fold(0.0, (sum, e) => sum + e.balance);
  }

}
