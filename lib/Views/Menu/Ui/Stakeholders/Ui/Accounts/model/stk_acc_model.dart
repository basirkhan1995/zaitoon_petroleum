// To parse this JSON data, do
//
//     final stakeholdersAccountsModel = stakeholdersAccountsModelFromMap(jsonString);

import 'dart:convert';

List<StakeholdersAccountsModel> stakeholdersAccountsModelFromMap(String str) => List<StakeholdersAccountsModel>.from(json.decode(str).map((x) => StakeholdersAccountsModel.fromMap(x)));

String stakeholdersAccountsModelToMap(List<StakeholdersAccountsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class StakeholdersAccountsModel {
  final int? accnumber;
  final String? accName;
  final String? actCurrency;
  final String? ccySymbol;
  final String? actCreditLimit;
  final String? curBalance;
  final String? avilBalance;
  final int? actStatus;

  StakeholdersAccountsModel({
    this.accnumber,
    this.accName,
    this.actCurrency,
    this.ccySymbol,
    this.actCreditLimit,
    this.curBalance,
    this.avilBalance,
    this.actStatus,
  });

  StakeholdersAccountsModel copyWith({
    int? accnumber,
    String? accName,
    String? actCurrency,
    String? ccySymbol,
    String? actCreditLimit,
    String? curBalance,
    String? avilBalance,
    int? actStatus,
  }) =>
      StakeholdersAccountsModel(
        accnumber: accnumber ?? this.accnumber,
        accName: accName ?? this.accName,
        actCurrency: actCurrency ?? this.actCurrency,
        ccySymbol: ccySymbol ?? this.ccySymbol,
        actCreditLimit: actCreditLimit ?? this.actCreditLimit,
        curBalance: curBalance ?? this.curBalance,
        avilBalance: avilBalance ?? this.avilBalance,
        actStatus: actStatus ?? this.actStatus,
      );

  factory StakeholdersAccountsModel.fromMap(Map<String, dynamic> json) => StakeholdersAccountsModel(
    accnumber: json["accnumber"],
    accName: json["accName"],
    actCurrency: json["actCurrency"],
    ccySymbol: json["ccySymbol"],
    actCreditLimit: json["actCreditLimit"],
    curBalance: json["curBalance"],
    avilBalance: json["avilBalance"],
    actStatus: json["actStatus"],
  );

  Map<String, dynamic> toMap() => {
    "accnumber": accnumber,
    "accName": accName,
    "actCurrency": actCurrency,
    "ccySymbol": ccySymbol,
    "actCreditLimit": actCreditLimit,
    "curBalance": curBalance,
    "avilBalance": avilBalance,
    "actStatus": actStatus,
  };
}
