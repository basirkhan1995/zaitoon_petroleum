// To parse this JSON data, do
//
//     final currenciesModel = currenciesModelFromMap(jsonString);

import 'dart:convert';

List<CurrenciesModel> currenciesModelFromMap(String str) => List<CurrenciesModel>.from(json.decode(str).map((x) => CurrenciesModel.fromMap(x)));

String currenciesModelToMap(List<CurrenciesModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class CurrenciesModel {
  final String? ccyCode;
  final String? ccyName;
  final String? ccySymbol;
  final String? ccyCountry;
  final int? ccyStatus;

  CurrenciesModel({
    this.ccyCode,
    this.ccyName,
    this.ccySymbol,
    this.ccyCountry,
    this.ccyStatus,
  });

  CurrenciesModel copyWith({
    String? ccyCode,
    String? ccyName,
    String? ccySymbol,
    String? ccyCountry,
    int? ccyStatus,
  }) =>
      CurrenciesModel(
        ccyCode: ccyCode ?? this.ccyCode,
        ccyName: ccyName ?? this.ccyName,
        ccySymbol: ccySymbol ?? this.ccySymbol,
        ccyCountry: ccyCountry ?? this.ccyCountry,
        ccyStatus: ccyStatus ?? this.ccyStatus,
      );

  factory CurrenciesModel.fromMap(Map<String, dynamic> json) => CurrenciesModel(
    ccyCode: json["ccyCode"],
    ccyName: json["ccyName"],
    ccySymbol: json["ccySymbol"],
    ccyCountry: json["ccyCountry"],
    ccyStatus: json["ccyStatus"],
  );

  Map<String, dynamic> toMap() => {
    "ccyCode": ccyCode,
    "ccyName": ccyName,
    "ccySymbol": ccySymbol,
    "ccyCountry": ccyCountry,
    "ccyStatus": ccyStatus,
  };
}
