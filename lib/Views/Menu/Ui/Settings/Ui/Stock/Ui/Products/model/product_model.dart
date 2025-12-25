// To parse this JSON data, do
//
//     final productsModel = productsModelFromMap(jsonString);

import 'dart:convert';

List<ProductsModel> productsModelFromMap(String str) => List<ProductsModel>.from(json.decode(str).map((x) => ProductsModel.fromMap(x)));

String productsModelToMap(List<ProductsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class ProductsModel {
  final int? proId;
  final String? proCode;
  final int? proCategory;
  final String? proName;
  final String? proMadeIn;
  final String? proDetails;
  final int? proStatus;

  ProductsModel({
    this.proId,
    this.proCode,
    this.proCategory,
    this.proName,
    this.proMadeIn,
    this.proDetails,
    this.proStatus,
  });

  ProductsModel copyWith({
    int? proId,
    String? proCode,
    int? proCategory,
    String? proName,
    String? proMadeIn,
    String? proDetails,
    int? proStatus,
  }) =>
      ProductsModel(
        proId: proId ?? this.proId,
        proCode: proCode ?? this.proCode,
        proCategory: proCategory ?? this.proCategory,
        proName: proName ?? this.proName,
        proMadeIn: proMadeIn ?? this.proMadeIn,
        proDetails: proDetails ?? this.proDetails,
        proStatus: proStatus ?? this.proStatus,
      );

  factory ProductsModel.fromMap(Map<String, dynamic> json) => ProductsModel(
    proId: json["proID"],
    proCode: json["proCode"],
    proCategory: json["proCategory"],
    proName: json["proName"],
    proMadeIn: json["proMadeIn"],
    proDetails: json["proDetails"],
    proStatus: json["proStatus"],
  );

  Map<String, dynamic> toMap() => {
    "proID": proId,
    "proCode": proCode,
    "proCategory": proCategory,
    "proName": proName,
    "proMadeIn": proMadeIn,
    "proDetails": proDetails,
    "proStatus": proStatus,
  };
}
