

import 'dart:convert';

GlatModel glatModelFromMap(String str) => GlatModel.fromMap(json.decode(str));

String glatModelToMap(GlatModel data) => json.encode(data.toMap());

class GlatModel {
  final int? vclId;
  final String? vclModel;
  final String? vclYear;
  final String? vclVinNo;
  final String? vclFuelType;
  final String? vclEnginPower;
  final String? vclBodyType;
  final String? vclPlateNo;
  final String? vclRegNo;
  final String? vclExpireDate;
  final int? vclOdoMeter;
  final String? vclPurchaseAmount;
  final String? driver;
  final int? vclStatus;
  final Transaction? transaction;

  GlatModel({
    this.vclId,
    this.vclModel,
    this.vclYear,
    this.vclVinNo,
    this.vclFuelType,
    this.vclEnginPower,
    this.vclBodyType,
    this.vclPlateNo,
    this.vclRegNo,
    this.vclExpireDate,
    this.vclOdoMeter,
    this.vclPurchaseAmount,
    this.driver,
    this.vclStatus,
    this.transaction,
  });

  GlatModel copyWith({
    int? vclId,
    String? vclModel,
    String? vclYear,
    String? vclVinNo,
    String? vclFuelType,
    String? vclEnginPower,
    String? vclBodyType,
    String? vclPlateNo,
    String? vclRegNo,
    String? vclExpireDate,
    int? vclOdoMeter,
    String? vclPurchaseAmount,
    String? driver,
    int? vclStatus,
    Transaction? transaction,
  }) =>
      GlatModel(
        vclId: vclId ?? this.vclId,
        vclModel: vclModel ?? this.vclModel,
        vclYear: vclYear ?? this.vclYear,
        vclVinNo: vclVinNo ?? this.vclVinNo,
        vclFuelType: vclFuelType ?? this.vclFuelType,
        vclEnginPower: vclEnginPower ?? this.vclEnginPower,
        vclBodyType: vclBodyType ?? this.vclBodyType,
        vclPlateNo: vclPlateNo ?? this.vclPlateNo,
        vclRegNo: vclRegNo ?? this.vclRegNo,
        vclExpireDate: vclExpireDate ?? this.vclExpireDate,
        vclOdoMeter: vclOdoMeter ?? this.vclOdoMeter,
        vclPurchaseAmount: vclPurchaseAmount ?? this.vclPurchaseAmount,
        driver: driver ?? this.driver,
        vclStatus: vclStatus ?? this.vclStatus,
        transaction: transaction ?? this.transaction,
      );

  factory GlatModel.fromMap(Map<String, dynamic> json) => GlatModel(
    vclId: json["vclID"],
    vclModel: json["vclModel"],
    vclYear: json["vclYear"],
    vclVinNo: json["vclVinNo"],
    vclFuelType: json["vclFuelType"],
    vclEnginPower: json["vclEnginPower"],
    vclBodyType: json["vclBodyType"],
    vclPlateNo: json["vclPlateNo"],
    vclRegNo: json["vclRegNo"],
    vclExpireDate: json["vclExpireDate"],
    vclOdoMeter: json["vclOdoMeter"],
    vclPurchaseAmount: json["vclPurchaseAmount"],
    driver: json["driver"],
    vclStatus: json["vclStatus"],
    transaction: json["transaction"] == null ? null : Transaction.fromMap(json["transaction"]),
  );

  Map<String, dynamic> toMap() => {
    "vclID": vclId,
    "vclModel": vclModel,
    "vclYear": vclYear,
    "vclVinNo": vclVinNo,
    "vclFuelType": vclFuelType,
    "vclEnginPower": vclEnginPower,
    "vclBodyType": vclBodyType,
    "vclPlateNo": vclPlateNo,
    "vclRegNo": vclRegNo,
    "vclExpireDate": vclExpireDate,
    "vclOdoMeter": vclOdoMeter,
    "vclPurchaseAmount": vclPurchaseAmount,
    "driver": driver,
    "vclStatus": vclStatus,
    "transaction": transaction?.toMap(),
  };
}

class Transaction {
  final String? trnReference;
  final String? purchaseAmount;
  final String? purchaseCurrency;
  final int? debitAccount;
  final int? creditAccount;
  final String? maker;
  final String? checker;
  final String? narration;

  Transaction({
    this.trnReference,
    this.purchaseAmount,
    this.purchaseCurrency,
    this.debitAccount,
    this.creditAccount,
    this.maker,
    this.checker,
    this.narration,
  });

  Transaction copyWith({
    String? trnReference,
    String? purchaseAmount,
    String? purchaseCurrency,
    int? debitAccount,
    int? creditAccount,
    String? maker,
    String? checker,
    String? narration,
  }) =>
      Transaction(
        trnReference: trnReference ?? this.trnReference,
        purchaseAmount: purchaseAmount ?? this.purchaseAmount,
        purchaseCurrency: purchaseCurrency ?? this.purchaseCurrency,
        debitAccount: debitAccount ?? this.debitAccount,
        creditAccount: creditAccount ?? this.creditAccount,
        maker: maker ?? this.maker,
        checker: checker ?? this.checker,
        narration: narration ?? this.narration,
      );

  factory Transaction.fromMap(Map<String, dynamic> json) => Transaction(
    trnReference: json["trnReference"],
    purchaseAmount: json["purchaseAmount"],
    purchaseCurrency: json["purchaseCurrency"],
    debitAccount: json["debitAccount"],
    creditAccount: json["creditAccount"],
    maker: json["maker"],
    checker: json["checker"],
    narration: json["narration"],
  );

  Map<String, dynamic> toMap() => {
    "trnReference": trnReference,
    "purchaseAmount": purchaseAmount,
    "purchaseCurrency": purchaseCurrency,
    "debitAccount": debitAccount,
    "creditAccount": creditAccount,
    "maker": maker,
    "checker": checker,
    "narration": narration,
  };
}
