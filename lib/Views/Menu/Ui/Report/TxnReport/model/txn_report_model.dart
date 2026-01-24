// To parse this JSON data, do
//
//     final transactionReportModel = transactionReportModelFromMap(jsonString);

import 'dart:convert';

List<TransactionReportModel> transactionReportModelFromMap(String str) => List<TransactionReportModel>.from(json.decode(str).map((x) => TransactionReportModel.fromMap(x)));

String transactionReportModelToMap(List<TransactionReportModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class TransactionReportModel {
  final int? no;
  final String? reference;
  final String? type;
  final int? status;
  final String? statusText;
  final String? maker;
  final String? checker;
  final String? currency;
  final String? actualAmount;
  final String? sysEquavalint;
  final DateTime? timing;

  TransactionReportModel({
    this.no,
    this.reference,
    this.type,
    this.status,
    this.statusText,
    this.maker,
    this.checker,
    this.currency,
    this.actualAmount,
    this.sysEquavalint,
    this.timing,
  });

  TransactionReportModel copyWith({
    int? no,
    String? reference,
    String? type,
    int? status,
    String? statusText,
    String? maker,
    String? checker,
    String? currency,
    String? actualAmount,
    String? sysEquavalint,
    DateTime? timing,
  }) =>
      TransactionReportModel(
        no: no ?? this.no,
        reference: reference ?? this.reference,
        type: type ?? this.type,
        status: status ?? this.status,
        statusText: statusText ?? this.statusText,
        maker: maker ?? this.maker,
        checker: checker ?? this.checker,
        currency: currency ?? this.currency,
        actualAmount: actualAmount ?? this.actualAmount,
        sysEquavalint: sysEquavalint ?? this.sysEquavalint,
        timing: timing ?? this.timing,
      );

  factory TransactionReportModel.fromMap(Map<String, dynamic> json) => TransactionReportModel(
    no: json["No"],
    reference: json["reference"],
    type: json["type"],
    status: json["status"],
    statusText: json["statusText"],
    maker: json["maker"],
    checker: json["checker"],
    currency: json["currency"],
    actualAmount: json["actual_amount"],
    sysEquavalint: json["sys_equavalint"],
    timing: json["timing"] == null ? null : DateTime.parse(json["timing"]),
  );

  Map<String, dynamic> toMap() => {
    "No": no,
    "reference": reference,
    "type": type,
    "status": status,
    "statusText": statusText,
    "maker": maker,
    "checker": checker,
    "currency": currency,
    "actual_amount": actualAmount,
    "sys_equavalint": sysEquavalint,
    "timing": timing?.toIso8601String(),
  };
}
