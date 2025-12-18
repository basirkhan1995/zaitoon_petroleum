// To parse this JSON data, do
//
//     final glAccountsModel = glAccountsModelFromMap(jsonString);

import 'dart:convert';

List<GlAccountsModel> glAccountsModelFromMap(String str) => List<GlAccountsModel>.from(json.decode(str).map((x) => GlAccountsModel.fromMap(x)));

String glAccountsModelToMap(List<GlAccountsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class GlAccountsModel {
  final int? accNumber;
  final int? accCategory;
  final String? accName;
  final String? usrName;

  GlAccountsModel({
    this.accNumber,
    this.accCategory,
    this.accName,
    this.usrName
  });

  GlAccountsModel copyWith({
    int? accNumber,
    int? accCategory,
    String? accName,
    String? usrName,
  }) =>
      GlAccountsModel(
        accNumber: accNumber ?? this.accNumber,
        accCategory: accCategory ?? this.accCategory,
        accName: accName ?? this.accName,
        usrName: usrName ?? this.usrName
      );

  factory GlAccountsModel.fromMap(Map<String, dynamic> json) => GlAccountsModel(
    accNumber: json["accNumber"],
    accCategory: json["accCategory"],
    accName: json["accName"],
    usrName: json["usrName"]
  );

  Map<String, dynamic> toMap() => {
    "accNumber": accNumber,
    "accCategory": accCategory,
    "accName": accName,
    "usrName": usrName
  };
}
