// To parse this JSON data, do
//
//     final transactionsModel = transactionsModelFromMap(jsonString);

import 'dart:convert';

List<TransactionsModel> transactionsModelFromMap(String str) => List<TransactionsModel>.from(json.decode(str).map((x) => TransactionsModel.fromMap(x)));

String transactionsModelToMap(List<TransactionsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class TransactionsModel {
  final String? trnType;
  final String? usrName;
  final int? account;
  final String? accCcy;
  final String? amount;
  final String? narration;

  TransactionsModel({
    this.trnType,
    this.usrName,
    this.account,
    this.accCcy,
    this.amount,
    this.narration,
  });

  TransactionsModel copyWith({
    String? trnType,
    String? usrName,
    int? account,
    String? accCcy,
    String? amount,
    String? narration,
  }) =>
      TransactionsModel(
        trnType: trnType ?? this.trnType,
        usrName: usrName ?? this.usrName,
        account: account ?? this.account,
        accCcy: accCcy ?? this.accCcy,
        amount: amount ?? this.amount,
        narration: narration ?? this.narration,
      );

  factory TransactionsModel.fromMap(Map<String, dynamic> json) => TransactionsModel(
    trnType: json["trnType"],
    usrName: json["usrName"],
    account: json["account"],
    accCcy: json["accCcy"],
    amount: json["amount"],
    narration: json["narration"],
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
