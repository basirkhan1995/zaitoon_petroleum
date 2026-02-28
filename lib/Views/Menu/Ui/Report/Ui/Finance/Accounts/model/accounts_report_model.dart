
import 'dart:convert';

List<AccountsReportModel> accountsReportModelFromMap(String str) => List<AccountsReportModel>.from(json.decode(str).map((x) => AccountsReportModel.fromMap(x)));

String accountsReportModelToMap(List<AccountsReportModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class AccountsReportModel {
  final int? accNumber;
  final String? accName;
  final int? ownerId;
  final String? ownerName;
  final String? actCurrency;
  final String? ccyName;
  final String? ccySymbol;
  final String? creditLimit;
  final String? status;

  AccountsReportModel({
    this.accNumber,
    this.accName,
    this.ownerId,
    this.ownerName,
    this.actCurrency,
    this.ccyName,
    this.ccySymbol,
    this.creditLimit,
    this.status,
  });

  AccountsReportModel copyWith({
    int? accNumber,
    String? accName,
    int? ownerId,
    String? ownerName,
    String? actCurrency,
    String? ccyName,
    String? ccySymbol,
    String? creditLimit,
    String? status,
  }) =>
      AccountsReportModel(
        accNumber: accNumber ?? this.accNumber,
        accName: accName ?? this.accName,
        ownerId: ownerId ?? this.ownerId,
        ownerName: ownerName ?? this.ownerName,
        actCurrency: actCurrency ?? this.actCurrency,
        ccyName: ccyName ?? this.ccyName,
        ccySymbol: ccySymbol ?? this.ccySymbol,
        creditLimit: creditLimit ?? this.creditLimit,
        status: status ?? this.status,
      );

  factory AccountsReportModel.fromMap(Map<String, dynamic> json) => AccountsReportModel(
    accNumber: json["accNumber"],
    accName: json["accName"],
    ownerId: json["ownerID"],
    ownerName: json["ownerName"],
    actCurrency: json["actCurrency"],
    ccyName: json["ccyName"],
    ccySymbol: json["ccySymbol"],
    creditLimit: json["creditLimit"],
    status: json["status"],
  );

  Map<String, dynamic> toMap() => {
    "accNumber": accNumber,
    "accName": accName,
    "ownerID": ownerId,
    "ownerName": ownerName,
    "actCurrency": actCurrency,
    "ccyName": ccyName,
    "ccySymbol": ccySymbol,
    "creditLimit": creditLimit,
    "status": status,
  };
}
