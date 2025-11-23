// To parse this JSON data, do
//
//     final exchangeRateModel = exchangeRateModelFromMap(jsonString);

import 'dart:convert';

List<ExchangeRateModel> exchangeRateModelFromMap(String str) => List<ExchangeRateModel>.from(json.decode(str).map((x) => ExchangeRateModel.fromMap(x)));

String exchangeRateModelToMap(List<ExchangeRateModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class ExchangeRateModel {
  final int? crId;
  final String? crFrom;
  final String? fromCode;
  final String? crTo;
  final String? toCode;
  final String? ccyLocalName;
  final String? crExchange;
  final DateTime? crDate;

  ExchangeRateModel({
    this.crId,
    this.crFrom,
    this.fromCode,
    this.crTo,
    this.toCode,
    this.ccyLocalName,
    this.crExchange,
    this.crDate,
  });

  ExchangeRateModel copyWith({
    int? crId,
    String? crFrom,
    String? fromCode,
    String? crTo,
    String? toCode,
    String? ccyLocalName,
    String? crExchange,
    DateTime? crDate,
  }) =>
      ExchangeRateModel(
        crId: crId ?? this.crId,
        crFrom: crFrom ?? this.crFrom,
        fromCode: fromCode ?? this.fromCode,
        crTo: crTo ?? this.crTo,
        toCode: toCode ?? this.toCode,
        ccyLocalName: ccyLocalName ?? this.ccyLocalName,
        crExchange: crExchange ?? this.crExchange,
        crDate: crDate ?? this.crDate,
      );

  factory ExchangeRateModel.fromMap(Map<String, dynamic> json) => ExchangeRateModel(
    crId: json["crID"],
    crFrom: json["crFrom"],
    fromCode: json["fromCode"],
    crTo: json["crTo"],
    toCode: json["toCode"],
    ccyLocalName: json["ccyLocalName"],
    crExchange: json["crExchange"],
    crDate: json["crDate"] == null ? null : DateTime.parse(json["crDate"]),
  );

  Map<String, dynamic> toMap() => {
    "crID": crId,
    "crFrom": crFrom,
    "fromCode": fromCode,
    "crTo": crTo,
    "toCode": toCode,
    "ccyLocalName": ccyLocalName,
    "crExchange": crExchange,
    "crDate": crDate?.toIso8601String(),
  };
}
