// To parse this JSON data, do
//
//     final allAccountsModel = allAccountsModelFromMap(jsonString);

import 'dart:convert';

AllAccountsModel allAccountsModelFromMap(String str) => AllAccountsModel.fromMap(json.decode(str));

String allAccountsModelToMap(AllAccountsModel data) => json.encode(data.toMap());

class AllAccountsModel {
  final int? accNumber;
  final String? accName;
  final String? actCurrency;
  final String? accBalance;
  final String? accCreditLimit;
  final int? accStatus;
  final int? accCategory;

  AllAccountsModel({
    this.accNumber,
    this.accName,
    this.actCurrency,
    this.accBalance,
    this.accCreditLimit,
    this.accStatus,
    this.accCategory,
  });

  AllAccountsModel copyWith({
    int? accNumber,
    String? accName,
    String? actCurrency,
    String? accBalance,
    String? accCreditLimit,
    int? accStatus,
    int? accCategory,
  }) =>
      AllAccountsModel(
        accNumber: accNumber ?? this.accNumber,
        accName: accName ?? this.accName,
        actCurrency: actCurrency ?? this.actCurrency,
        accBalance: accBalance ?? this.accBalance,
        accCreditLimit: accCreditLimit ?? this.accCreditLimit,
        accStatus: accStatus ?? this.accStatus,
        accCategory: accCategory ?? this.accCategory,
      );

  factory AllAccountsModel.fromMap(Map<String, dynamic> json) => AllAccountsModel(
    accNumber: json["accNumber"],
    accName: json["accName"],
    actCurrency: json["actCurrency"],
    accBalance: json["accBalance"],
    accCreditLimit: json["accCreditLimit"],
    accStatus: json["accStatus"],
    accCategory: json["accCategory"],
  );

  Map<String, dynamic> toMap() => {
    "accNumber": accNumber,
    "accName": accName,
    "actCurrency": actCurrency,
    "accBalance": accBalance,
    "accCreditLimit": accCreditLimit,
    "accStatus": accStatus,
    "accCategory": accCategory,
  };
}
