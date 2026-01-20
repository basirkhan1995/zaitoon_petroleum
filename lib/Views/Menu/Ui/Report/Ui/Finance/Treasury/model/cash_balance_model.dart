// To parse this JSON data, do
//
//     final cashBalancesModel = cashBalancesModelFromMap(jsonString);

import 'dart:convert';

List<CashBalancesModel> cashBalancesModelFromMap(String str) => List<CashBalancesModel>.from(json.decode(str).map((x) => CashBalancesModel.fromMap(x)));

String cashBalancesModelToMap(List<CashBalancesModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class CashBalancesModel {
  final int? brcId;
  final int? brcCompany;
  final String? brcName;
  final int? brcAddress;
  final String? brcPhone;
  final int? brcStatus;
  final DateTime? brcEntryDate;
  final String? address;
  final List<Record>? records;

  CashBalancesModel({
    this.brcId,
    this.brcCompany,
    this.brcName,
    this.brcAddress,
    this.brcPhone,
    this.brcStatus,
    this.brcEntryDate,
    this.address,
    this.records,
  });

  CashBalancesModel copyWith({
    int? brcId,
    int? brcCompany,
    String? brcName,
    int? brcAddress,
    String? brcPhone,
    int? brcStatus,
    DateTime? brcEntryDate,
    String? address,
    List<Record>? records,
  }) =>
      CashBalancesModel(
        brcId: brcId ?? this.brcId,
        brcCompany: brcCompany ?? this.brcCompany,
        brcName: brcName ?? this.brcName,
        brcAddress: brcAddress ?? this.brcAddress,
        brcPhone: brcPhone ?? this.brcPhone,
        brcStatus: brcStatus ?? this.brcStatus,
        brcEntryDate: brcEntryDate ?? this.brcEntryDate,
        address: address ?? this.address,
        records: records ?? this.records,
      );

  factory CashBalancesModel.fromMap(Map<String, dynamic> json) => CashBalancesModel(
    brcId: json["brcID"],
    brcCompany: json["brcCompany"],
    brcName: json["brcName"],
    brcAddress: json["brcAddress"],
    brcPhone: json["brcPhone"],
    brcStatus: json["brcStatus"],
    brcEntryDate: json["brcEntryDate"] == null ? null : DateTime.parse(json["brcEntryDate"]),
    address: json["address"],
    records: json["records"] == null ? [] : List<Record>.from(json["records"]!.map((x) => Record.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "brcID": brcId,
    "brcCompany": brcCompany,
    "brcName": brcName,
    "brcAddress": brcAddress,
    "brcPhone": brcPhone,
    "brcStatus": brcStatus,
    "brcEntryDate": brcEntryDate?.toIso8601String(),
    "address": address,
    "records": records == null ? [] : List<dynamic>.from(records!.map((x) => x.toMap())),
  };
}

class Record {
  final String? accName;
  final int? trdAccount;
  final String? ccyName;
  final String? trdCcy;
  final String? openingBalance;
  final String? openingSysEquivalent;
  final String? closingBalance;
  final String? closingSysEquivalent;

  Record({
    this.accName,
    this.trdAccount,
    this.ccyName,
    this.trdCcy,
    this.openingBalance,
    this.openingSysEquivalent,
    this.closingBalance,
    this.closingSysEquivalent,
  });

  Record copyWith({
    String? accName,
    int? trdAccount,
    String? ccyName,
    String? trdCcy,
    String? openingBalance,
    String? openingSysEquivalent,
    String? closingBalance,
    String? closingSysEquivalent,
  }) =>
      Record(
        accName: accName ?? this.accName,
        trdAccount: trdAccount ?? this.trdAccount,
        ccyName: ccyName ?? this.ccyName,
        trdCcy: trdCcy ?? this.trdCcy,
        openingBalance: openingBalance ?? this.openingBalance,
        openingSysEquivalent: openingSysEquivalent ?? this.openingSysEquivalent,
        closingBalance: closingBalance ?? this.closingBalance,
        closingSysEquivalent: closingSysEquivalent ?? this.closingSysEquivalent,
      );

  factory Record.fromMap(Map<String, dynamic> json) => Record(
    accName: json["accName"],
    trdAccount: json["trdAccount"],
    ccyName: json["ccyName"],
    trdCcy: json["trdCcy"],
    openingBalance: json["opening_balance"],
    openingSysEquivalent: json["opening_sys_equivalent"],
    closingBalance: json["closing_balance"],
    closingSysEquivalent: json["closing_sys_equivalent"],
  );

  Map<String, dynamic> toMap() => {
    "accName": accName,
    "trdAccount": trdAccount,
    "ccyName": ccyName,
    "trdCcy": trdCcy,
    "opening_balance": openingBalance,
    "opening_sys_equivalent": openingSysEquivalent,
    "closing_balance": closingBalance,
    "closing_sys_equivalent": closingSysEquivalent,
  };
}
