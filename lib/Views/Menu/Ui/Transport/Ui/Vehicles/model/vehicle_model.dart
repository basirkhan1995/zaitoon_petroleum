import 'dart:convert';

VehicleModel vehicleModelFromMap(String str) => VehicleModel.fromMap(json.decode(str));

String vehicleModelToMap(VehicleModel data) => json.encode(data.toMap());

class VehicleModel {
  final int? vclId;
  final String? vclModel;
  final String? vclYear;
  final String? vclVinNo;
  final String? vclFuelType;
  final String? vclEnginPower;
  final String? vclBodyType;
  final String? vclPlateNo;
  final String? vclRegNo;
  final DateTime? vclExpireDate;
  final String? vclOwnership;
  final int? vclOdoMeter;
  final String? vclPurchaseAmount;
  final int? vclPurchaseAccount;
  final String? vclPurchaseTrnRef;
  final String? driver;
  final int? vclStatus;
  final String? usrName;
  final int? driverId;

  VehicleModel({
    this.vclId,
    this.vclModel,
    this.vclYear,
    this.vclVinNo,
    this.driverId,
    this.vclFuelType,
    this.vclEnginPower,
    this.vclBodyType,
    this.vclPlateNo,
    this.vclRegNo,
    this.vclExpireDate,
    this.vclOwnership,
    this.vclOdoMeter,
    this.vclPurchaseAmount,
    this.vclPurchaseAccount,
    this.vclPurchaseTrnRef,
    this.driver,
    this.vclStatus,
    this.usrName
  });

  VehicleModel copyWith({
    int? vclId,
    String? vclModel,
    String? vclYear,
    String? vclVinNo,
    String? vclFuelType,
    String? vclEnginPower,
    String? vclBodyType,
    String? vclPlateNo,
    String? vclRegNo,
    DateTime? vclExpireDate,
    String? vclOwnership,
    int? vclOdoMeter,
    String? vclPurchaseAmount,
    int? vclPurchaseAccount,
    String? vclPurchaseTrnRef,
    String? driver,
    int? perId,
    int? vclStatus,
    String? usrName,
  }) =>
      VehicleModel(
        vclId: vclId ?? this.vclId,
        vclModel: vclModel ?? this.vclModel,
        vclYear: vclYear ?? this.vclYear,
        vclVinNo: vclVinNo ?? this.vclVinNo,
        vclFuelType: vclFuelType ?? this.vclFuelType,
        vclEnginPower: vclEnginPower ?? this.vclEnginPower,
        vclBodyType: vclBodyType ?? this.vclBodyType,
        vclPlateNo: vclPlateNo ?? this.vclPlateNo,
        vclRegNo: vclRegNo ?? this.vclRegNo,
        vclExpireDate: vclExpireDate ?? this.vclExpireDate,
        vclOwnership: vclOwnership ?? this.vclOwnership,
        vclOdoMeter: vclOdoMeter ?? this.vclOdoMeter,
        vclPurchaseAmount: vclPurchaseAmount ?? this.vclPurchaseAmount,
        vclPurchaseAccount: vclPurchaseAccount ?? this.vclPurchaseAccount,
        vclPurchaseTrnRef: vclPurchaseTrnRef ?? this.vclPurchaseTrnRef,
        driver: driver ?? this.driver,
        vclStatus: vclStatus ?? this.vclStatus,
        usrName: usrName ?? this.usrName
      );

  factory VehicleModel.fromMap(Map<String, dynamic> json) => VehicleModel(
    vclId: json["vclID"],
    vclModel: json["vclModel"],
    vclYear: json["vclYear"],
    vclVinNo: json["vclVinNo"],
    vclFuelType: json["vclFuelType"],
    vclEnginPower: json["vclEnginPower"],
    vclBodyType: json["vclBodyType"],
    vclPlateNo: json["vclPlateNo"],
    vclRegNo: json["vclRegNo"],
    driverId: json["vclDriver"],
    vclExpireDate: json["vclExpireDate"] == null ? null : DateTime.parse(json["vclExpireDate"]),
    vclOwnership: json["vclOwnership"],
    vclOdoMeter: json["vclOdoMeter"],
    vclPurchaseAmount: json["vclPurchaseAmount"],
    vclPurchaseAccount: json["vclPurchaseAccount"],
    vclPurchaseTrnRef: json["vclPurchaseTrnRef"],
    driver: json["driver"],
    vclStatus: json["vclStatus"],
    usrName: json["user"]
  );

  Map<String, dynamic> toMap() => {
    "vclID": vclId,
    "vclModel": vclModel,
    "vclYear": vclYear,
    "vclVinNo": vclVinNo,
    "vclFuelType": vclFuelType,
    "vclEnginPower": vclEnginPower,
    "vclBodyType": vclBodyType,
    "vclPlateNo": vclPlateNo,
    "vclRegNo": vclRegNo,
    "vclExpireDate": "${vclExpireDate!.year.toString().padLeft(4, '0')}-${vclExpireDate!.month.toString().padLeft(2, '0')}-${vclExpireDate!.day.toString().padLeft(2, '0')}",
    "vclOwnership": vclOwnership,
    "vclOdoMeter": vclOdoMeter,
    "vclPurchaseAmount": vclPurchaseAmount,
    "vclPurchaseAccount": vclPurchaseAccount,
    "vclPurchaseTrnRef": vclPurchaseTrnRef,
    "driver": driver,
    "vclDriver": driverId,
    "vclStatus": vclStatus,
    "user":usrName,
  };
}
