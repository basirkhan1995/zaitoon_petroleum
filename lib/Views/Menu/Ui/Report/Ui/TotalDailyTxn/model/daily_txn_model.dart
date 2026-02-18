
import 'dart:convert';

List<TotalDailyTxnModel> totalDailyTxnModelFromMap(String str) => List<TotalDailyTxnModel>.from(json.decode(str).map((x) => TotalDailyTxnModel.fromMap(x)));
String totalDailyTxnModelToMap(List<TotalDailyTxnModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class TotalDailyTxnModel {
  final String? txnName;
  final double? totalAmount;
  final int? totalCount;

  TotalDailyTxnModel({
    this.txnName,
    this.totalAmount,
    this.totalCount,
  });

  TotalDailyTxnModel copyWith({
    String? txnName,
    double? totalAmount,
    int? totalCount,
  }) =>
      TotalDailyTxnModel(
        txnName: txnName ?? this.txnName,
        totalAmount: totalAmount ?? this.totalAmount,
        totalCount: totalCount ?? this.totalCount,
      );

  factory TotalDailyTxnModel.fromMap(Map<String, dynamic> json) =>
      TotalDailyTxnModel(
        txnName: json["trntName"],
        totalAmount: double.tryParse(json["total"].toString()) ?? 0.0,
        totalCount: int.tryParse(json["total_trn"] ?? "0") ?? 0,
      );

  Map<String, dynamic> toMap() => {
    "trntName": txnName,
    "total": totalAmount,
    "total_trn": totalCount,
  };
}
