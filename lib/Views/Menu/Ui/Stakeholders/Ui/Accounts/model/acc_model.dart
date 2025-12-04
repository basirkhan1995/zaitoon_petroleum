// To parse this JSON data, do
//
//     final accountsModel = accountsModelFromMap(jsonString);

import 'dart:convert';

List<AccountsModel> accountsModelFromMap(String str) => List<AccountsModel>.from(json.decode(str).map((x) => AccountsModel.fromMap(x)));

String accountsModelToMap(List<AccountsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class AccountsModel {
  final int? accNumber;
  final int? accCategory;
  final String? accName;
  final int? actId;
  final int? actAccount;
  final String? actCurrency;
  final String? actCreditLimit;
  final int? actSignatory;
  final int? actCompany;
  final int? actStatus;
  final String? accBalance;

  AccountsModel({
    this.accNumber,
    this.accCategory,
    this.accName,
    this.actId,
    this.actAccount,
    this.actCurrency,
    this.actCreditLimit,
    this.actSignatory,
    this.accBalance,
    this.actCompany,
    this.actStatus,
  });

  AccountsModel copyWith({
    int? accNumber,
    int? accCategory,
    String? accName,
    int? actId,
    int? actAccount,
    String? actCurrency,
    String? actCreditLimit,
    int? actSignatory,
    int? actCompany,
    int? actStatus,
    String? accBalance,
  }) =>
      AccountsModel(
        accNumber: accNumber ?? this.accNumber,
        accCategory: accCategory ?? this.accCategory,
        accName: accName ?? this.accName,
        actId: actId ?? this.actId,
        actAccount: actAccount ?? this.actAccount,
        actCurrency: actCurrency ?? this.actCurrency,
        actCreditLimit: actCreditLimit ?? this.actCreditLimit,
        actSignatory: actSignatory ?? this.actSignatory,
        actCompany: actCompany ?? this.actCompany,
        actStatus: actStatus ?? this.actStatus,
        accBalance: accBalance ?? this.accBalance,
      );

  factory AccountsModel.fromMap(Map<String, dynamic> json) => AccountsModel(
    accNumber: json["accNumber"],
    accCategory: json["accCategory"],
    accName: json["accName"],
    actId: json["actID"],
    actAccount: json["actAccount"],
    actCurrency: json["actCurrency"],
    actCreditLimit: json["actCreditLimit"],
    accBalance: json["actCreditLimit"],
    actSignatory: json["actSignatory"],
    actCompany: json["actCompany"],
    actStatus: json["actStatus"],
  );

  Map<String, dynamic> toMap() => {
    "accNumber": accNumber,
    "accCategory": accCategory,
    "accName": accName,
    "actID": actId,
    "actAccount": actAccount,
    "actCurrency": actCurrency,
    "actCreditLimit": actCreditLimit,
    "actSignatory": actSignatory,
    "actCompany": actCompany,
    "actStatus": actStatus,
  };
}
