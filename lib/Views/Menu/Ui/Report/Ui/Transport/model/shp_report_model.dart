// To parse this JSON data, do
//
//     final shippingReportModel = shippingReportModelFromMap(jsonString);

import 'dart:convert';

List<ShippingReportModel> shippingReportModelFromMap(String str) => List<ShippingReportModel>.from(json.decode(str).map((x) => ShippingReportModel.fromMap(x)));

String shippingReportModelToMap(List<ShippingReportModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class ShippingReportModel {
  final int? no;
  final int? shpId;
  final String? vehicle;
  final String? driverName;
  final String? proName;
  final String? customerName;
  final String? shpFrom;
  final DateTime? shpMovingDate;
  final String? shpLoadSize;
  final String? shpUnit;
  final String? shpTo;
  final DateTime? shpArriveDate;
  final String? shpUnloadSize;
  final String? shpRent;
  final String? total;
  final int? shpStatus;

  ShippingReportModel({
    this.no,
    this.shpId,
    this.vehicle,
    this.driverName,
    this.proName,
    this.customerName,
    this.shpFrom,
    this.shpMovingDate,
    this.shpLoadSize,
    this.shpUnit,
    this.shpTo,
    this.shpArriveDate,
    this.shpUnloadSize,
    this.shpRent,
    this.total,
    this.shpStatus,
  });

  ShippingReportModel copyWith({
    int? no,
    int? shpId,
    String? vehicle,
    String? driverName,
    String? proName,
    String? customerName,
    String? shpFrom,
    DateTime? shpMovingDate,
    String? shpLoadSize,
    String? shpUnit,
    String? shpTo,
    DateTime? shpArriveDate,
    String? shpUnloadSize,
    String? shpRent,
    String? total,
    int? shpStatus,
  }) =>
      ShippingReportModel(
        no: no ?? this.no,
        shpId: shpId ?? this.shpId,
        vehicle: vehicle ?? this.vehicle,
        driverName: driverName ?? this.driverName,
        proName: proName ?? this.proName,
        customerName: customerName ?? this.customerName,
        shpFrom: shpFrom ?? this.shpFrom,
        shpMovingDate: shpMovingDate ?? this.shpMovingDate,
        shpLoadSize: shpLoadSize ?? this.shpLoadSize,
        shpUnit: shpUnit ?? this.shpUnit,
        shpTo: shpTo ?? this.shpTo,
        shpArriveDate: shpArriveDate ?? this.shpArriveDate,
        shpUnloadSize: shpUnloadSize ?? this.shpUnloadSize,
        shpRent: shpRent ?? this.shpRent,
        total: total ?? this.total,
        shpStatus: shpStatus ?? this.shpStatus,
      );

  factory ShippingReportModel.fromMap(Map<String, dynamic> json) => ShippingReportModel(
    no: json["No"],
    shpId: json["shpID"],
    vehicle: json["vehicle"],
    driverName: json["driverName"],
    proName: json["proName"],
    customerName: json["customerName"],
    shpFrom: json["shpFrom"],
    shpMovingDate: json["shpMovingDate"] == null ? null : DateTime.parse(json["shpMovingDate"]),
    shpLoadSize: json["shpLoadSize"],
    shpUnit: json["shpUnit"],
    shpTo: json["shpTo"],
    shpArriveDate: json["shpArriveDate"] == null ? null : DateTime.parse(json["shpArriveDate"]),
    shpUnloadSize: json["shpUnloadSize"],
    shpRent: json["shpRent"],
    total: json["total"],
    shpStatus: json["shpStatus"],
  );

  Map<String, dynamic> toMap() => {
    "No": no,
    "shpID": shpId,
    "vehicle": vehicle,
    "driverName": driverName,
    "proName": proName,
    "customerName": customerName,
    "shpFrom": shpFrom,
    "shpMovingDate": "${shpMovingDate!.year.toString().padLeft(4, '0')}-${shpMovingDate!.month.toString().padLeft(2, '0')}-${shpMovingDate!.day.toString().padLeft(2, '0')}",
    "shpLoadSize": shpLoadSize,
    "shpUnit": shpUnit,
    "shpTo": shpTo,
    "shpArriveDate": "${shpArriveDate!.year.toString().padLeft(4, '0')}-${shpArriveDate!.month.toString().padLeft(2, '0')}-${shpArriveDate!.day.toString().padLeft(2, '0')}",
    "shpUnloadSize": shpUnloadSize,
    "shpRent": shpRent,
    "total": total,
    "shpStatus": shpStatus,
  };
}
