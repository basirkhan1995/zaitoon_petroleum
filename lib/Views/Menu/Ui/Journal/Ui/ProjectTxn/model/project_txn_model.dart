// To parse this JSON data, do
//
//     final projectTxnModel = projectTxnModelFromMap(jsonString);

import 'dart:convert';

ProjectTxnModel projectTxnModelFromMap(String str) => ProjectTxnModel.fromMap(json.decode(str));

String projectTxnModelToMap(ProjectTxnModel data) => json.encode(data.toMap());

class ProjectTxnModel {
  final int? prjId;
  final String? prjName;
  final String? customerName;
  final String? prjLocation;
  final String? prjDetails;
  final DateTime? prjDateLine;
  final int? prjStatus;
  final String? prpType;
  final Transaction? transaction;

  ProjectTxnModel({
    this.prjId,
    this.prjName,
    this.customerName,
    this.prjLocation,
    this.prjDetails,
    this.prjDateLine,
    this.prjStatus,
    this.prpType,
    this.transaction,
  });

  ProjectTxnModel copyWith({
    int? prjId,
    String? prjName,
    String? customerName,
    String? prjLocation,
    String? prjDetails,
    DateTime? prjDateLine,
    int? prjStatus,
    String? prpType,
    Transaction? transaction,
  }) =>
      ProjectTxnModel(
        prjId: prjId ?? this.prjId,
        prjName: prjName ?? this.prjName,
        customerName: customerName ?? this.customerName,
        prjLocation: prjLocation ?? this.prjLocation,
        prjDetails: prjDetails ?? this.prjDetails,
        prjDateLine: prjDateLine ?? this.prjDateLine,
        prjStatus: prjStatus ?? this.prjStatus,
        prpType: prpType ?? this.prpType,
        transaction: transaction ?? this.transaction,
      );

  factory ProjectTxnModel.fromMap(Map<String, dynamic> json) => ProjectTxnModel(
    prjId: json["prjID"],
    prjName: json["prjName"],
    customerName: json["customerName"],
    prjLocation: json["prjLocation"],
    prjDetails: json["prjDetails"],
    prjDateLine: json["prjDateLine"] == null ? null : DateTime.parse(json["prjDateLine"]),
    prjStatus: json["prjStatus"],
    prpType: json["prpType"],
    transaction: json["transaction"] == null ? null : Transaction.fromMap(json["transaction"]),
  );

  Map<String, dynamic> toMap() => {
    "prjID": prjId,
    "prjName": prjName,
    "customerName": customerName,
    "prjLocation": prjLocation,
    "prjDetails": prjDetails,
    "prjDateLine": "${prjDateLine!.year.toString().padLeft(4, '0')}-${prjDateLine!.month.toString().padLeft(2, '0')}-${prjDateLine!.day.toString().padLeft(2, '0')}",
    "prjStatus": prjStatus,
    "prpType": prpType,
    "transaction": transaction?.toMap(),
  };
}

class Transaction {
  final String? trnReference;
  final String? amount;
  final String? currency;
  final int? debitAccount;
  final int? creditAccount;
  final String? maker;
  final String? checker;
  final String? narration;
  final int? trnStatus;
  final String? trnStateText;

  Transaction({
    this.trnReference,
    this.amount,
    this.currency,
    this.debitAccount,
    this.creditAccount,
    this.maker,
    this.checker,
    this.narration,
    this.trnStatus,
    this.trnStateText,
  });

  Transaction copyWith({
    String? trnReference,
    String? amount,
    String? currency,
    int? debitAccount,
    int? creditAccount,
    String? maker,
    String? checker,
    String? narration,
    int? trnStatus,
    String? trnStateText,
  }) =>
      Transaction(
        trnReference: trnReference ?? this.trnReference,
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
        debitAccount: debitAccount ?? this.debitAccount,
        creditAccount: creditAccount ?? this.creditAccount,
        maker: maker ?? this.maker,
        checker: checker ?? this.checker,
        narration: narration ?? this.narration,
        trnStatus: trnStatus ?? this.trnStatus,
        trnStateText: trnStateText ?? this.trnStateText,
      );

  factory Transaction.fromMap(Map<String, dynamic> json) => Transaction(
    trnReference: json["trnReference"],
    amount: json["amount"],
    currency: json["currency"],
    debitAccount: json["debitAccount"],
    creditAccount: json["creditAccount"],
    maker: json["maker"],
    checker: json["checker"],
    narration: json["narration"],
    trnStatus: json["trnStatus"],
    trnStateText: json["trnStateText"],
  );

  Map<String, dynamic> toMap() => {
    "trnReference": trnReference,
    "amount": amount,
    "currency": currency,
    "debitAccount": debitAccount,
    "creditAccount": creditAccount,
    "maker": maker,
    "checker": checker,
    "narration": narration,
    "trnStatus": trnStatus,
    "trnStateText": trnStateText,
  };
}
