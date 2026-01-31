// To parse this JSON data, do
//
//     final productsStockModel = productsStockModelFromMap(jsonString);

import 'dart:convert';

List<ProductsStockModel> productsStockModelFromMap(String str) => List<ProductsStockModel>.from(json.decode(str).map((x) => ProductsStockModel.fromMap(x)));

String productsStockModelToMap(List<ProductsStockModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class ProductsStockModel {
  final int? proId;
  final String? proName;
  final String? proCode;
  final int? stkStorage;
  final String? stgName;
  final String? available;
  final String? averagePrice;
  final String? recentPrice;
  final String? sellPrice;

  ProductsStockModel({
    this.proId,
    this.proName,
    this.proCode,
    this.stkStorage,
    this.stgName,
    this.available,
    this.averagePrice,
    this.recentPrice,
    this.sellPrice,
  });

  ProductsStockModel copyWith({
    int? proId,
    String? proName,
    String? proCode,
    int? stkStorage,
    String? stgName,
    String? available,
    String? recentPrice,
    String? averagePrice,
    String? sellPrice,
  }) =>
      ProductsStockModel(
        proId: proId ?? this.proId,
        proName: proName ?? this.proName,
        proCode: proCode ?? this.proCode,
        stkStorage: stkStorage ?? this.stkStorage,
        stgName: stgName ?? this.stgName,
        available: available ?? this.available,
        averagePrice: averagePrice ?? this.averagePrice,
        recentPrice: recentPrice ?? this.recentPrice,
        sellPrice: sellPrice ?? this.sellPrice,
      );

  factory ProductsStockModel.fromMap(Map<String, dynamic> json) => ProductsStockModel(
    proId: json["proID"],
    proName: json["proName"],
    proCode: json["proCode"],
    stkStorage: json["stkStorage"],
    stgName: json["stgName"],
    available: json["available"],
    averagePrice: json["average_price"],
    recentPrice: json["recent_price"],
    sellPrice: json["sell_price"],
  );

  Map<String, dynamic> toMap() => {
    "proID": proId,
    "proName": proName,
    "proCode": proCode,
    "stkStorage": stkStorage,
    "stgName": stgName,
    "available": available,
    "average_price": averagePrice,
    "recent_price": recentPrice,
    "sell_price": sellPrice,
  };
}
