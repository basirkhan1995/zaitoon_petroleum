// To parse this JSON data, do
//
//     final trptModel = trptModelFromMap(jsonString);

import 'dart:convert';

TrptModel trptModelFromMap(String str) => TrptModel.fromMap(json.decode(str));

String trptModelToMap(TrptModel data) => json.encode(data.toMap());

class TrptModel {
  final int? shpId;
  final String? vehicle;
  final String? proName;
  final String? customer;
  final String? shpFrom;
  final DateTime? shpMovingDate;
  final String? shpLoadSize;
  final String? shpUnit;
  final String? shpTo;
  final DateTime? shpArriveDate;
  final String? shpUnloadSize;
  final String? shpRent;
  final String? total;
  final int? shpStatus;
  final String? shdTrnRef;
  final TrtpTransaction? transaction;

  TrptModel({
    this.shpId,
    this.vehicle,
    this.proName,
    this.customer,
    this.shpFrom,
    this.shpMovingDate,
    this.shpLoadSize,
    this.shpUnit,
    this.shpTo,
    this.shpArriveDate,
    this.shpUnloadSize,
    this.shpRent,
    this.total,
    this.shpStatus,
    this.shdTrnRef,
    this.transaction,
  });

  TrptModel copyWith({
    int? shpId,
    String? vehicle,
    String? proName,
    String? customer,
    String? shpFrom,
    DateTime? shpMovingDate,
    String? shpLoadSize,
    String? shpUnit,
    String? shpTo,
    DateTime? shpArriveDate,
    String? shpUnloadSize,
    String? shpRent,
    String? total,
    int? shpStatus,
    String? shdTrnRef,
    TrtpTransaction? transaction,
  }) =>
      TrptModel(
        shpId: shpId ?? this.shpId,
        vehicle: vehicle ?? this.vehicle,
        proName: proName ?? this.proName,
        customer: customer ?? this.customer,
        shpFrom: shpFrom ?? this.shpFrom,
        shpMovingDate: shpMovingDate ?? this.shpMovingDate,
        shpLoadSize: shpLoadSize ?? this.shpLoadSize,
        shpUnit: shpUnit ?? this.shpUnit,
        shpTo: shpTo ?? this.shpTo,
        shpArriveDate: shpArriveDate ?? this.shpArriveDate,
        shpUnloadSize: shpUnloadSize ?? this.shpUnloadSize,
        shpRent: shpRent ?? this.shpRent,
        total: total ?? this.total,
        shpStatus: shpStatus ?? this.shpStatus,
        shdTrnRef: shdTrnRef ?? this.shdTrnRef,
        transaction: transaction ?? this.transaction,
      );

  factory TrptModel.fromMap(Map<String, dynamic> json) => TrptModel(
    shpId: json["shpID"],
    vehicle: json["vehicle"],
    proName: json["proName"],
    customer: json["customer"],
    shpFrom: json["shpFrom"],
    shpMovingDate: json["shpMovingDate"] == null ? null : DateTime.parse(json["shpMovingDate"]),
    shpLoadSize: json["shpLoadSize"],
    shpUnit: json["shpUnit"],
    shpTo: json["shpTo"],
    shpArriveDate: json["shpArriveDate"] == null ? null : DateTime.parse(json["shpArriveDate"]),
    shpUnloadSize: json["shpUnloadSize"],
    shpRent: json["shpRent"],
    total: json["total"],
    shpStatus: json["shpStatus"],
    shdTrnRef: json["shdTrnRef"],
    transaction: json["transaction"] == null ? null : TrtpTransaction.fromMap(json["transaction"]),
  );

  Map<String, dynamic> toMap() => {
    "shpID": shpId,
    "vehicle": vehicle,
    "proName": proName,
    "customer": customer,
    "shpFrom": shpFrom,
    "shpMovingDate": shpMovingDate?.toIso8601String(),
    "shpLoadSize": shpLoadSize,
    "shpUnit": shpUnit,
    "shpTo": shpTo,
    "shpArriveDate": shpArriveDate?.toIso8601String(),
    "shpUnloadSize": shpUnloadSize,
    "shpRent": shpRent,
    "total": total,
    "shpStatus": shpStatus,
    "shdTrnRef": shdTrnRef,
    "transaction": transaction?.toMap(),
  };
}

class TrtpTransaction {
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

  TrtpTransaction({
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

  TrtpTransaction copyWith({
    String? trnReference,
    String? purchaseAmount,
    String? purchaseCurrency,
    int? debitAccount,
    int? creditAccount,
    String? maker,
    String? checker,
    String? narration,
    int? trnStatus,
    String? trnStateText,
  }) =>
      TrtpTransaction(
        trnReference: trnReference ?? this.trnReference,
        amount: purchaseAmount ?? amount,
        currency: purchaseCurrency ?? currency,
        debitAccount: debitAccount ?? this.debitAccount,
        creditAccount: creditAccount ?? this.creditAccount,
        maker: maker ?? this.maker,
        checker: checker ?? this.checker,
        narration: narration ?? this.narration,
        trnStatus: trnStatus ?? this.trnStatus,
        trnStateText: trnStateText ?? this.trnStateText,
      );

  factory TrtpTransaction.fromMap(Map<String, dynamic> json) => TrtpTransaction(
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
