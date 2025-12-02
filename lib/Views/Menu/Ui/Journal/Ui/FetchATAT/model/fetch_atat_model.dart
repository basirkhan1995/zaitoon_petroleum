// To parse this JSON data, do
//
//     final fetchAtatModel = fetchAtatModelFromMap(jsonString);

import 'dart:convert';

FetchAtatModel fetchAtatModelFromMap(String str) => FetchAtatModel.fromMap(json.decode(str));

String fetchAtatModelToMap(FetchAtatModel data) => json.encode(data.toMap());

class FetchAtatModel {
  final String? trnReference;
  final String? trnType;
  final int? trnStatus;
  final String? maker;
  final String? checker;
  final String? trdNarration;
  final int? trdBranch;
  final String? trnStateText;
  final DateTime? trnEntryDate;
  final String? type;
  final List<Records>? debit;
  final List<Records>? credit;

  FetchAtatModel({
    this.trnReference,
    this.trnType,
    this.trnStatus,
    this.maker,
    this.checker,
    this.trdNarration,
    this.trdBranch,
    this.trnStateText,
    this.trnEntryDate,
    this.type,
    this.debit,
    this.credit,
  });

  FetchAtatModel copyWith({
    String? trnReference,
    String? trnType,
    int? trnStatus,
    String? maker,
    String? checker,
    String? trdNarration,
    int? trdBranch,
    String? trnStateText,
    DateTime? trnEntryDate,
    String? type,
    List<Records>? debit,
    List<Records>? credit,
  }) =>
      FetchAtatModel(
        trnReference: trnReference ?? this.trnReference,
        trnType: trnType ?? this.trnType,
        trnStatus: trnStatus ?? this.trnStatus,
        maker: maker ?? this.maker,
        checker: checker ?? this.checker,
        trdNarration: trdNarration ?? this.trdNarration,
        trdBranch: trdBranch ?? this.trdBranch,
        trnStateText: trnStateText ?? this.trnStateText,
        trnEntryDate: trnEntryDate ?? this.trnEntryDate,
        type: type ?? this.type,
        debit: debit ?? this.debit,
        credit: credit ?? this.credit,
      );

  factory FetchAtatModel.fromMap(Map<String, dynamic> json) => FetchAtatModel(
    trnReference: json["trnReference"],
    trnType: json["trnType"],
    trnStatus: json["trnStatus"],
    maker: json["maker"],
    checker: json["checker"],
    trdNarration: json["trdNarration"],
    trdBranch: json["trdBranch"],
    trnStateText: json["trnStateText"],
    trnEntryDate: json["trnEntryDate"] == null ? null : DateTime.parse(json["trnEntryDate"]),
    type: json["type"],
    debit: json["debit"] == null ? [] : List<Records>.from(json["debit"]!.map((x) => Records.fromMap(x))),
    credit: json["credit"] == null ? [] : List<Records>.from(json["credit"]!.map((x) => Records.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "trnReference": trnReference,
    "trnType": trnType,
    "trnStatus": trnStatus,
    "maker": maker,
    "checker": checker,
    "trdNarration": trdNarration,
    "trdBranch": trdBranch,
    "trnStateText": trnStateText,
    "trnEntryDate": trnEntryDate?.toIso8601String(),
    "type": type,
    "debit": debit == null ? [] : List<dynamic>.from(debit!.map((x) => x.toMap())),
    "credit": credit == null ? [] : List<dynamic>.from(credit!.map((x) => x.toMap())),
  };
}

class Records {
  final int? trdAccount;
  final String? accName;
  final String? trdCcy;
  final String? trdAmount;
  final String? trdDrCr;

  Records({
    this.trdAccount,
    this.accName,
    this.trdCcy,
    this.trdAmount,
    this.trdDrCr,
  });

  Records copyWith({
    int? trdAccount,
    String? accName,
    String? trdCcy,
    String? trdAmount,
    String? trdDrCr,
  }) =>
      Records(
        trdAccount: trdAccount ?? this.trdAccount,
        accName: accName ?? this.accName,
        trdCcy: trdCcy ?? this.trdCcy,
        trdAmount: trdAmount ?? this.trdAmount,
        trdDrCr: trdDrCr ?? this.trdDrCr,
      );

  factory Records.fromMap(Map<String, dynamic> json) => Records(
    trdAccount: json["trdAccount"],
    accName: json["accName"],
    trdCcy: json["trdCcy"],
    trdAmount: json["trdAmount"],
    trdDrCr: json["trdDrCr"],
  );

  Map<String, dynamic> toMap() => {
    "trdAccount": trdAccount,
    "accName": accName,
    "trdCcy": trdCcy,
    "trdAmount": trdAmount,
    "trdDrCr": trdDrCr,
  };
}
