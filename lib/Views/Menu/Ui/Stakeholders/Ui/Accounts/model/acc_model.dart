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
  final String? accCreditLimit;
  final int? actSignatory;
  final int? actCompany;
  final int? accStatus;
  final String? accBalance;
  final String? accAvailBalance;

  AccountsModel({
    this.accAvailBalance,
    this.accNumber,
    this.accCategory,
    this.accName,
    this.actId,
    this.actAccount,
    this.actCurrency,
    this.accCreditLimit,
    this.actSignatory,
    this.accBalance,
    this.actCompany,
    this.accStatus,
  });

  AccountsModel copyWith({
    String? accAvailBalance,
    int? accNumber,
    int? accCategory,
    String? accName,
    int? actId,
    int? actAccount,
    String? actCurrency,
    String? accCreditLimit,
    int? actSignatory,
    int? actCompany,
    int? accStatus,
    String? accBalance,
  }) =>
      AccountsModel(
        accAvailBalance: accAvailBalance ?? this.accAvailBalance,
        accNumber: accNumber ?? this.accNumber,
        accCategory: accCategory ?? this.accCategory,
        accName: accName ?? this.accName,
        actId: actId ?? this.actId,
        actAccount: actAccount ?? this.actAccount,
        actCurrency: actCurrency ?? this.actCurrency,
        accCreditLimit: accCreditLimit ?? this.accCreditLimit,
        actSignatory: actSignatory ?? this.actSignatory,
        actCompany: actCompany ?? this.actCompany,
        accStatus: accStatus ?? this.accStatus,
        accBalance: accBalance ?? this.accBalance,
      );

  factory AccountsModel.fromMap(Map<String, dynamic> json) => AccountsModel(
    accAvailBalance: json["accAvailBalance"],
    accNumber: json["accNumber"],
    accCategory: json["accCategory"],
    accName: json["accName"],
    actId: json["actID"],
    actAccount: json["actAccount"],
    actCurrency: json["actCurrency"],
   // accCreditLimit: json["accCreditLimit"],
    accCreditLimit: json["actCreditLimit"],
    accBalance: json["accBalance"],
    actSignatory: json["actSignatory"],
    actCompany: json["actCompany"],
    //accStatus: json["accStatus"],
    accStatus: json["actStatus"],
  );

  Map<String, dynamic> toMap() => {
    "accAvailBalance":accAvailBalance,
    "accNumber": accNumber,
    "accCategory": accCategory,
    "accName": accName,
    "actID": actId,
    "actAccount": actAccount,
    "actCurrency": actCurrency,
    "actCreditLimit": accCreditLimit,
    "actSignatory": actSignatory,
    "actCompany": actCompany,
    "actStatus": accStatus,
  };
}
