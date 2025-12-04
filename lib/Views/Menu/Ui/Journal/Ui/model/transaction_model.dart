
import 'dart:convert';

TransactionsModel transactionsModel2FromMap(String str) => TransactionsModel.fromMap(json.decode(str));

String transactionsModel2ToMap(TransactionsModel data) => json.encode(data.toMap());

class TransactionsModel {
  final String? trnReference;
  final String? trnType;
  final String? trntName;
  final int? trdBranch;
  final String? maker;
  final String? checker;
  final int? trnStatus;
  final String? trnStateText;
  final DateTime? trnEntryDate;

  ///Cash transaction
  final String? usrName;
  final String? trdNarration;
  final String? trdCcy;
  final int? trdAccount;
  final String? trdAmount;

  ///Account to Account
  final int? fromAccount;
  final int? toAccount;
  final String? fromAccCy;
  final String? toAccCcy;

  TransactionsModel({
    this.trnReference,
    this.trnType,
    this.trntName,
    this.maker,
    this.checker,
    this.trnStatus,
    this.trdBranch,
    this.trnStateText,
    this.trnEntryDate,

    this.usrName,
    this.trdNarration,
    this.trdAmount,
    this.trdAccount,
    this.trdCcy,

    this.fromAccount,
    this.toAccount,
    this.fromAccCy,
    this.toAccCcy
  });

  TransactionsModel copyWith({
    String? trnReference,
    String? trnType,
    String? trntName,
    String? maker,
    String? checker,
    int? trnStatus,
    String? trnStateText,
    DateTime? trnEntryDate,
  }) =>
      TransactionsModel(
        trnReference: trnReference ?? this.trnReference,
        trnType: trnType ?? this.trnType,
        trntName: trntName ?? this.trntName,
        maker: maker ?? this.maker,
        checker: checker ?? this.checker,
        trnStatus: trnStatus ?? this.trnStatus,
        trnStateText: trnStateText ?? this.trnStateText,
        trnEntryDate: trnEntryDate ?? this.trnEntryDate,
      );

  factory TransactionsModel.fromMap(Map<String, dynamic> json) => TransactionsModel(
    trnReference: json["trnReference"],
    trdAccount: json["trdAccount"],
    trdCcy: json["trdCcy"],
    trdNarration: json["trdNarration"],
    trdAmount: json["trdAmount"],
    trdBranch: json["trdBranch"],
    trnType: json["trnType"],
    trntName: json["trntName"],
    maker: json["maker"],
    checker: json["checker"],
    trnStatus: json["trnStatus"],
    trnStateText: json["trnStateText"],
    trnEntryDate: json["trnEntryDate"] == null ? null : DateTime.parse(json["trnEntryDate"]),
  );

  Map<String, dynamic> toMap() => {
    "reference":trnReference,
    "trnType": trnType,
    "usrName": usrName,
    "account": trdAccount,
    "accCcy": trdCcy,
    "amount": trdAmount,
    "narration": trdNarration,

    "fromAccount": fromAccount,
    "fromAccCcy": fromAccCy,
    "toAccount": toAccount,
    "toAccCcy": toAccCcy,
  };
}
