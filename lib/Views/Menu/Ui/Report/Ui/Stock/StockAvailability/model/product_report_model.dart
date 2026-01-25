// To parse this JSON data, do
//
//     final productReportModel = productReportModelFromMap(jsonString);

import 'dart:convert';

List<ProductReportModel> productReportModelFromMap(String str) => List<ProductReportModel>.from(json.decode(str).map((x) => ProductReportModel.fromMap(x)));

String productReportModelToMap(List<ProductReportModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class ProductReportModel {
  final int? no;
  final String? proName;
  final int? proId;
  final String? proCode;
  final String? stgName;
  final int? stkStorage;
  final String? availableQuantity;
  final String? pricePerUnit;
  final String? total;

  ProductReportModel({
    this.no,
    this.proName,
    this.proId,
    this.proCode,
    this.stgName,
    this.stkStorage,
    this.availableQuantity,
    this.pricePerUnit,
    this.total,
  });

  ProductReportModel copyWith({
    int? no,
    String? proName,
    int? proId,
    String? proCode,
    String? stgName,
    int? stkStorage,
    String? availableQuantity,
    String? pricePerUnit,
    String? total,
  }) =>
      ProductReportModel(
        no: no ?? this.no,
        proName: proName ?? this.proName,
        proId: proId ?? this.proId,
        proCode: proCode ?? this.proCode,
        stgName: stgName ?? this.stgName,
        stkStorage: stkStorage ?? this.stkStorage,
        availableQuantity: availableQuantity ?? this.availableQuantity,
        pricePerUnit: pricePerUnit ?? this.pricePerUnit,
        total: total ?? this.total,
      );

  factory ProductReportModel.fromMap(Map<String, dynamic> json) => ProductReportModel(
    no: json["No"],
    proName: json["proName"],
    proId: json["proID"],
    proCode: json["proCode"],
    stgName: json["stgName"],
    stkStorage: json["stkStorage"],
    availableQuantity: json["available_quantity"],
    pricePerUnit: json["pricePerUnit"],
    total: json["total"],
  );

  Map<String, dynamic> toMap() => {
    "No": no,
    "proName": proName,
    "proID": proId,
    "proCode": proCode,
    "stgName": stgName,
    "stkStorage": stkStorage,
    "available_quantity": availableQuantity,
    "pricePerUnit": pricePerUnit,
    "total": total,
  };
}
