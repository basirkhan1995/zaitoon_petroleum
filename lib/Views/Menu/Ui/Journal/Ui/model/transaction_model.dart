// To parse this JSON data, do
//
//     final transactionsModel = transactionsModelFromMap(jsonString);

import 'dart:convert';

List<TransactionsModel> transactionsModelFromMap(String str) => List<TransactionsModel>.from(json.decode(str).map((x) => TransactionsModel.fromMap(x)));

String transactionsModelToMap(List<TransactionsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class TransactionsModel {
  final String? trnReference;
  final String? trnType;
  final String? trntName;
  final String? maker;
  final String? checker;
  final int? trnStatus;
  final DateTime? trnEntryDate;

  final String? usrName;
  final String? narration;
  final String? accCcy;
  final int? account;
  final String? amount;

  TransactionsModel({
    this.trnReference,
    this.trnType,
    this.trntName,
    this.maker,
    this.checker,
    this.trnStatus,
    this.trnEntryDate,

    this.usrName,
    this.narration,
    this.amount,
    this.account,
    this.accCcy
  });

  TransactionsModel copyWith({
    String? trnReference,
    String? trnType,
    String? trntName,
    String? maker,
    String? checker,
    int? trnStatus,
    DateTime? trnEntryDate,
  }) =>
      TransactionsModel(
        trnReference: trnReference ?? this.trnReference,
        trnType: trnType ?? this.trnType,
        trntName: trntName ?? this.trntName,
        maker: maker ?? this.maker,
        checker: checker ?? this.checker,
        trnStatus: trnStatus ?? this.trnStatus,
        trnEntryDate: trnEntryDate ?? this.trnEntryDate,
      );

  factory TransactionsModel.fromMap(Map<String, dynamic> json) => TransactionsModel(
    trnReference: json["trnReference"],
    trnType: json["trnType"],
    trntName: json["trntName"],
    maker: json["maker"],
    checker: json["checker"],
    trnStatus: json["trnStatus"],
    trnEntryDate: json["trnEntryDate"] == null ? null : DateTime.parse(json["trnEntryDate"]),
  );

  Map<String, dynamic> toMap() => {
    "trnType": trnType,
    "usrName": usrName,
    "account": account,
    "accCcy": accCcy,
    "amount": amount,
    "narration": narration,
  };
}



