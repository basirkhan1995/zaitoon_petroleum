// To parse this JSON data, do
//
//     final vehicleReportModel = vehicleReportModelFromMap(jsonString);

import 'dart:convert';

List<VehicleReportModel> vehicleReportModelFromMap(String str) => List<VehicleReportModel>.from(json.decode(str).map((x) => VehicleReportModel.fromMap(x)));

String vehicleReportModelToMap(List<VehicleReportModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class VehicleReportModel {
  final int? vclId;
  final String? vclModel;
  final String? vclYear;
  final String? vclVinNo;
  final String? vclFuelType;
  final String? vclEnginPower;
  final String? vclBodyType;
  final String? vclRegNo;
  final DateTime? vclExpireDate;
  final String? vclPlateNo;
  final int? vclOdoMeter;
  final String? vclOwnership;
  final String? vclPurchaseAmount;
  final int? vclPurchaseAccount;
  final String? vclPurchaseTrnRef;
  final DateTime? vclEntryDate;
  final int? vclStatus;
  final int? vclDriver;
  final String? driverName;

  VehicleReportModel({
    this.vclId,
    this.vclModel,
    this.vclYear,
    this.vclVinNo,
    this.vclFuelType,
    this.vclEnginPower,
    this.vclBodyType,
    this.vclRegNo,
    this.vclExpireDate,
    this.vclPlateNo,
    this.vclOdoMeter,
    this.vclOwnership,
    this.vclPurchaseAmount,
    this.vclPurchaseAccount,
    this.vclPurchaseTrnRef,
    this.vclEntryDate,
    this.vclStatus,
    this.vclDriver,
    this.driverName,
  });

  VehicleReportModel copyWith({
    int? vclId,
    String? vclModel,
    String? vclYear,
    String? vclVinNo,
    String? vclFuelType,
    String? vclEnginPower,
    String? vclBodyType,
    String? vclRegNo,
    DateTime? vclExpireDate,
    String? vclPlateNo,
    int? vclOdoMeter,
    String? vclOwnership,
    String? vclPurchaseAmount,
    int? vclPurchaseAccount,
    String? vclPurchaseTrnRef,
    DateTime? vclEntryDate,
    int? vclStatus,
    int? vclDriver,
    String? driverName,
  }) =>
      VehicleReportModel(
        vclId: vclId ?? this.vclId,
        vclModel: vclModel ?? this.vclModel,
        vclYear: vclYear ?? this.vclYear,
        vclVinNo: vclVinNo ?? this.vclVinNo,
        vclFuelType: vclFuelType ?? this.vclFuelType,
        vclEnginPower: vclEnginPower ?? this.vclEnginPower,
        vclBodyType: vclBodyType ?? this.vclBodyType,
        vclRegNo: vclRegNo ?? this.vclRegNo,
        vclExpireDate: vclExpireDate ?? this.vclExpireDate,
        vclPlateNo: vclPlateNo ?? this.vclPlateNo,
        vclOdoMeter: vclOdoMeter ?? this.vclOdoMeter,
        vclOwnership: vclOwnership ?? this.vclOwnership,
        vclPurchaseAmount: vclPurchaseAmount ?? this.vclPurchaseAmount,
        vclPurchaseAccount: vclPurchaseAccount ?? this.vclPurchaseAccount,
        vclPurchaseTrnRef: vclPurchaseTrnRef ?? this.vclPurchaseTrnRef,
        vclEntryDate: vclEntryDate ?? this.vclEntryDate,
        vclStatus: vclStatus ?? this.vclStatus,
        vclDriver: vclDriver ?? this.vclDriver,
        driverName: driverName ?? this.driverName,
      );

  factory VehicleReportModel.fromMap(Map<String, dynamic> json) => VehicleReportModel(
    vclId: json["vclID"],
    vclModel: json["vclModel"],
    vclYear: json["vclYear"],
    vclVinNo: json["vclVinNo"],
    vclFuelType: json["vclFuelType"],
    vclEnginPower: json["vclEnginPower"],
    vclBodyType: json["vclBodyType"],
    vclRegNo: json["vclRegNo"],
    vclExpireDate: json["vclExpireDate"] == null ? null : DateTime.parse(json["vclExpireDate"]),
    vclPlateNo: json["vclPlateNo"],
    vclOdoMeter: json["vclOdoMeter"],
    vclOwnership: json["vclOwnership"],
    vclPurchaseAmount: json["vclPurchaseAmount"],
    vclPurchaseAccount: json["vclPurchaseAccount"],
    vclPurchaseTrnRef: json["vclPurchaseTrnRef"],
    vclEntryDate: json["vclEntryDate"] == null ? null : DateTime.parse(json["vclEntryDate"]),
    vclStatus: json["vclStatus"],
    vclDriver: json["vclDriver"],
    driverName: json["driverName"],
  );

  Map<String, dynamic> toMap() => {
    "vclID": vclId,
    "vclModel": vclModel,
    "vclYear": vclYear,
    "vclVinNo": vclVinNo,
    "vclFuelType": vclFuelType,
    "vclEnginPower": vclEnginPower,
    "vclBodyType": vclBodyType,
    "vclRegNo": vclRegNo,
    "vclExpireDate": "${vclExpireDate!.year.toString().padLeft(4, '0')}-${vclExpireDate!.month.toString().padLeft(2, '0')}-${vclExpireDate!.day.toString().padLeft(2, '0')}",
    "vclPlateNo": vclPlateNo,
    "vclOdoMeter": vclOdoMeter,
    "vclOwnership": vclOwnership,
    "vclPurchaseAmount": vclPurchaseAmount,
    "vclPurchaseAccount": vclPurchaseAccount,
    "vclPurchaseTrnRef": vclPurchaseTrnRef,
    "vclEntryDate": vclEntryDate?.toIso8601String(),
    "vclStatus": vclStatus,
    "vclDriver": vclDriver,
    "driverName": driverName,
  };
}
