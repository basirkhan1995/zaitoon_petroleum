import 'dart:convert';

DriverModel driverModelFromMap(String str) => DriverModel.fromMap(json.decode(str));

String driverModelToMap(DriverModel data) => json.encode(data.toMap());

class DriverModel {
  final int? empId;
  final String? perfullName;
  final String? perPhone;
  final String? perPhoto;
  final String? address;
  final DateTime? empHireDate;
  final int? empStatus;
  final String? vehicle;

  DriverModel({
    this.empId,
    this.perfullName,
    this.perPhone,
    this.perPhoto,
    this.address,
    this.empHireDate,
    this.empStatus,
    this.vehicle,
  });

  DriverModel copyWith({
    int? empId,
    String? perfullName,
    String? perPhone,
    String? perPhoto,
    String? address,
    DateTime? empHireDate,
    int? empStatus,
    String? vehicle,
  }) =>
      DriverModel(
        empId: empId ?? this.empId,
        perfullName: perfullName ?? this.perfullName,
        perPhone: perPhone ?? this.perPhone,
        perPhoto: perPhoto ?? this.perPhoto,
        address: address ?? this.address,
        empHireDate: empHireDate ?? this.empHireDate,
        empStatus: empStatus ?? this.empStatus,
        vehicle: vehicle ?? this.vehicle,
      );

  factory DriverModel.fromMap(Map<String, dynamic> json) => DriverModel(
    empId: json["empID"],
    perfullName: json["perfullName"],
    perPhone: json["perPhone"],
    perPhoto: json["perPhoto"],
    address: json["address"],
    empHireDate: json["empHireDate"] == null ? null : DateTime.parse(json["empHireDate"]),
    empStatus: json["empStatus"],
    vehicle: json["vehicle"],
  );

  Map<String, dynamic> toMap() => {
    "empID": empId,
    "perfullName": perfullName,
    "perPhone": perPhone,
    "perPhoto": perPhoto,
    "address": address,
    "empHireDate": "${empHireDate!.year.toString().padLeft(4, '0')}-${empHireDate!.month.toString().padLeft(2, '0')}-${empHireDate!.day.toString().padLeft(2, '0')}",
    "empStatus": empStatus,
    "vehicle": vehicle,
  };
}
