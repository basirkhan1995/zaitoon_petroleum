// To parse this JSON data, do
//
//     final txnByReferenceModel = txnByReferenceModelFromMap(jsonString);

import 'dart:convert';

List<TxnByReferenceModel> txnByReferenceModelFromMap(String str) => List<TxnByReferenceModel>.from(json.decode(str).map((x) => TxnByReferenceModel.fromMap(x)));

String txnByReferenceModelToMap(List<TxnByReferenceModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class TxnByReferenceModel {
  final String? trnReference;
  final String? trnType;
  final int? trnStatus;
  final String? trnStatusText;
  final String? maker;
  final dynamic checker;
  final int? account;
  final String? accName;
  final String? amount;
  final String? currency;
  final String? narration;
  final int? branch;
  final DateTime? trnEntryDate;

  TxnByReferenceModel({
    this.trnReference,
    this.trnType,
    this.trnStatus,
    this.trnStatusText,
    this.maker,
    this.checker,
    this.account,
    this.accName,
    this.amount,
    this.currency,
    this.narration,
    this.branch,
    this.trnEntryDate,
  });

  TxnByReferenceModel copyWith({
    String? trnReference,
    String? trnType,
    int? trnStatus,
    String? maker,
    dynamic checker,
    int? account,
    String? accName,
    String? amount,
    String? currency,
    String? narration,
    int? branch,
    DateTime? trnEntryDate,
  }) =>
      TxnByReferenceModel(
        trnReference: trnReference ?? this.trnReference,
        trnType: trnType ?? this.trnType,
        trnStatus: trnStatus ?? this.trnStatus,
        maker: maker ?? this.maker,
        checker: checker ?? this.checker,
        account: account ?? this.account,
        accName: accName ?? this.accName,
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
        narration: narration ?? this.narration,
        branch: branch ?? this.branch,
        trnEntryDate: trnEntryDate ?? this.trnEntryDate,
      );

  factory TxnByReferenceModel.fromMap(Map<String, dynamic> json) => TxnByReferenceModel(
    trnReference: json["trnReference"],
    trnType: json["trnType"],
    trnStatus: json["trnStatus"],
    maker: json["maker"],
    checker: json["checker"],
    account: json["account"],
    accName: json["accName"],
    amount: json["amount"],
    currency: json["currency"],
    trnStatusText: json["trnStateText"],
    narration: json["narration"],
    branch: json["branch"],
    trnEntryDate: json["trnEntryDate"] == null ? null : DateTime.parse(json["trnEntryDate"]),
  );

  Map<String, dynamic> toMap() => {
    "trnReference": trnReference,
    "trnType": trnType,
    "trnStatus": trnStatus,
    "trnStateText": trnStatusText,
    "maker": maker,
    "checker": checker,
    "account": account,
    "accName": accName,
    "amount": amount,
    "currency": currency,
    "narration": narration,
    "branch": branch,
    "trnEntryDate": trnEntryDate?.toIso8601String(),
  };
}
