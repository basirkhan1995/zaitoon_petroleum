
import 'dart:convert';

FetchAtatModel fetchAtatModelFromMap(String str) => FetchAtatModel.fromMap(json.decode(str));

String fetchAtatModelToMap(FetchAtatModel data) => json.encode(data.toMap());

class FetchAtatModel {
  final String? trnReference;
  final String? trnType;
  final int? trnStatus;
  final String? usrName;
  final DateTime? trnEntryDate;
  final String? trnStateText;
  final String? type;
  final List<Records>? debit;
  final List<Records>? credit;

  FetchAtatModel({
    this.trnReference,
    this.trnType,
    this.trnStatus,
    this.usrName,
    this.trnEntryDate,
    this.trnStateText,
    this.type,
    this.debit,
    this.credit,
  });

  FetchAtatModel copyWith({
    String? trnReference,
    String? trnType,
    int? trnStatus,
    String? usrName,
    DateTime? trnEntryDate,
    String? trnStateText,
    String? type,
    List<Records>? debit,
    List<Records>? credit,
  }) =>
      FetchAtatModel(
        trnReference: trnReference ?? this.trnReference,
        trnType: trnType ?? this.trnType,
        trnStatus: trnStatus ?? this.trnStatus,
        usrName: usrName ?? this.usrName,
        trnEntryDate: trnEntryDate ?? this.trnEntryDate,
        trnStateText: trnStateText ?? this.trnStateText,
        type: type ?? this.type,
        debit: debit ?? this.debit,
        credit: credit ?? this.credit,
      );

  factory FetchAtatModel.fromMap(Map<String, dynamic> json) => FetchAtatModel(
    trnReference: json["trnReference"],
    trnType: json["trnType"],
    trnStatus: json["trnStatus"],
    usrName: json["usrName"],
    trnEntryDate: json["trnEntryDate"] == null ? null : DateTime.parse(json["trnEntryDate"]),
    trnStateText: json["trnStateText"],
    type: json["type"],
    debit: json["debit"] == null ? [] : List<Records>.from(json["debit"]!.map((x) => Records.fromMap(x))),
    credit: json["credit"] == null ? [] : List<Records>.from(json["credit"]!.map((x) => Records.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "trnReference": trnReference,
    "trnType": trnType,
    "trnStatus": trnStatus,
    "usrName": usrName,
    "trnEntryDate": trnEntryDate?.toIso8601String(),
    "trnStateText": trnStateText,
    "type": type,
    "debit": debit == null ? [] : List<dynamic>.from(debit!.map((x) => x.toMap())),
    "credit": credit == null ? [] : List<dynamic>.from(credit!.map((x) => x.toMap())),
  };
}

class Records {
  final int? trdId;
  final String? trdReference;
  final String? trdCcy;
  final int? trdBranch;
  final int? trdAccount;
  final String? trdDrCr;
  final String? trdAmount;
  final String? trdNarration;
  final DateTime? trdEntryDate;

  Records({
    this.trdId,
    this.trdReference,
    this.trdCcy,
    this.trdBranch,
    this.trdAccount,
    this.trdDrCr,
    this.trdAmount,
    this.trdNarration,
    this.trdEntryDate,
  });

  Records copyWith({
    int? trdId,
    String? trdReference,
    String? trdCcy,
    int? trdBranch,
    int? trdAccount,
    String? trdDrCr,
    String? trdAmount,
    String? trdNarration,
    DateTime? trdEntryDate,
  }) =>
      Records(
        trdId: trdId ?? this.trdId,
        trdReference: trdReference ?? this.trdReference,
        trdCcy: trdCcy ?? this.trdCcy,
        trdBranch: trdBranch ?? this.trdBranch,
        trdAccount: trdAccount ?? this.trdAccount,
        trdDrCr: trdDrCr ?? this.trdDrCr,
        trdAmount: trdAmount ?? this.trdAmount,
        trdNarration: trdNarration ?? this.trdNarration,
        trdEntryDate: trdEntryDate ?? this.trdEntryDate,
      );

  factory Records.fromMap(Map<String, dynamic> json) => Records(
    trdId: json["trdID"],
    trdReference: json["trdReference"],
    trdCcy: json["trdCcy"],
    trdBranch: json["trdBranch"],
    trdAccount: json["trdAccount"],
    trdDrCr: json["trdDrCr"],
    trdAmount: json["trdAmount"],
    trdNarration: json["trdNarration"],
    trdEntryDate: json["trdEntryDate"] == null ? null : DateTime.parse(json["trdEntryDate"]),
  );

  Map<String, dynamic> toMap() => {
    "trdID": trdId,
    "trdReference": trdReference,
    "trdCcy": trdCcy,
    "trdBranch": trdBranch,
    "trdAccount": trdAccount,
    "trdDrCr": trdDrCr,
    "trdAmount": trdAmount,
    "trdNarration": trdNarration,
    "trdEntryDate": trdEntryDate?.toIso8601String(),
  };
}
