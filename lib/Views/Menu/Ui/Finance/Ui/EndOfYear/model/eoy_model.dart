
import 'dart:convert';

List<PAndLModel> pAndLModelFromMap(String str) => List<PAndLModel>.from(json.decode(str).map((x) => PAndLModel.fromMap(x)));

String pAndLModelToMap(List<PAndLModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class PAndLModel {
  final int? trdBranch;
  final int? accountNumber;
  final String? accountName;
  final String? currency;
  final String? category;
  final String? debit;
  final String? credit;

  PAndLModel({
    this.trdBranch,
    this.accountNumber,
    this.accountName,
    this.currency,
    this.category,
    this.debit,
    this.credit,
  });

  PAndLModel copyWith({
    int? trdBranch,
    int? accountNumber,
    String? accountName,
    String? currency,
    String? category,
    String? debit,
    String? credit,
  }) =>
      PAndLModel(
        trdBranch: trdBranch ?? this.trdBranch,
        accountNumber: accountNumber ?? this.accountNumber,
        accountName: accountName ?? this.accountName,
        currency: currency ?? this.currency,
        category: category ?? this.category,
        debit: debit ?? this.debit,
        credit: credit ?? this.credit,
      );

  factory PAndLModel.fromMap(Map<String, dynamic> json) => PAndLModel(
    trdBranch: json["trdBranch"],
    accountNumber: json["account_number"],
    accountName: json["account_name"],
    currency: json["currency"],
    category: json["category"],
    debit: json["debit"],
    credit: json["credit"],
  );

  Map<String, dynamic> toMap() => {
    "trdBranch": trdBranch,
    "account_number": accountNumber,
    "account_name": accountName,
    "currency": currency,
    "category": category,
    "debit": debit,
    "credit": credit,
  };
}
