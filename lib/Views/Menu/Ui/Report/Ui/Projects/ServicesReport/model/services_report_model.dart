// To parse this JSON data, do
//
//     final servicesReportModel = servicesReportModelFromMap(jsonString);

import 'dart:convert';

List<ServicesReportModel> servicesReportModelFromMap(String str) => List<ServicesReportModel>.from(json.decode(str).map((x) => ServicesReportModel.fromMap(x)));

String servicesReportModelToMap(List<ServicesReportModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class ServicesReportModel {
  final String? serviceName;
  final String? projectName;
  final DateTime? entryDate;
  final String? pjdQuantity;
  final String? pjdPricePerQty;
  final String? totalAmount;

  ServicesReportModel({
    this.serviceName,
    this.projectName,
    this.entryDate,
    this.pjdQuantity,
    this.pjdPricePerQty,
    this.totalAmount,
  });

  ServicesReportModel copyWith({
    String? serviceName,
    String? projectName,
    DateTime? entryDate,
    String? pjdQuantity,
    String? pjdPricePerQty,
    String? totalAmount,
  }) =>
      ServicesReportModel(
        serviceName: serviceName ?? this.serviceName,
        projectName: projectName ?? this.projectName,
        entryDate: entryDate ?? this.entryDate,
        pjdQuantity: pjdQuantity ?? this.pjdQuantity,
        pjdPricePerQty: pjdPricePerQty ?? this.pjdPricePerQty,
        totalAmount: totalAmount ?? this.totalAmount,
      );

  factory ServicesReportModel.fromMap(Map<String, dynamic> json) => ServicesReportModel(
    serviceName: json["ServiceName"],
    projectName: json["ProjectName"],
    entryDate: json["EntryDate"] == null ? null : DateTime.parse(json["EntryDate"]),
    pjdQuantity: json["pjdQuantity"],
    pjdPricePerQty: json["pjdPricePerQty"],
    totalAmount: json["totalAmount"],
  );

  Map<String, dynamic> toMap() => {
    "ServiceName": serviceName,
    "ProjectName": projectName,
    "EntryDate": "${entryDate!.year.toString().padLeft(4, '0')}-${entryDate!.month.toString().padLeft(2, '0')}-${entryDate!.day.toString().padLeft(2, '0')}",
    "pjdQuantity": pjdQuantity,
    "pjdPricePerQty": pjdPricePerQty,
    "totalAmount": totalAmount,
  };
}
