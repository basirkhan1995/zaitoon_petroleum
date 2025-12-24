import 'dart:convert';

List<ShippingModel> shippingModelFromMap(String str) => List<ShippingModel>.from(json.decode(str).map((x) => ShippingModel.fromMap(x)));

String shippingModelToMap(List<ShippingModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class ShippingModel {
  final int? shpId;
  final String? vehicle;
  final int? perId;
  final String? proName;
  final int? productId;
  final int? customerId;
  final int? vehicleId;
  final String? customer;
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
  final String? usrName;
  final String? advanceAmount;
  final String? remark;
  ShippingModel({
    this.shpId,
    this.vehicle,
    this.proName,
    this.perId,
    this.customer,
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
    this.productId,
    this.vehicleId,
    this.customerId,
    this.advanceAmount,
    this.remark,
    this.usrName,
  });

  ShippingModel copyWith({
    int? shpId,
    String? vehicle,
    String? proName,
    String? customer,
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
    int? productId,
    int? customerId,
    int? perId,
    int? vehicleId,
    String? remark,
    String? advanceAmount,
    String? usrName,
  }) =>
      ShippingModel(
        shpId: shpId ?? this.shpId,
        vehicle: vehicle ?? this.vehicle,
        proName: proName ?? this.proName,
        customer: customer ?? this.customer,
        shpFrom: shpFrom ?? this.shpFrom,
        perId: perId ?? this.perId,
        shpMovingDate: shpMovingDate ?? this.shpMovingDate,
        shpLoadSize: shpLoadSize ?? this.shpLoadSize,
        shpUnit: shpUnit ?? this.shpUnit,
        shpTo: shpTo ?? this.shpTo,
        shpArriveDate: shpArriveDate ?? this.shpArriveDate,
        shpUnloadSize: shpUnloadSize ?? this.shpUnloadSize,
        shpRent: shpRent ?? this.shpRent,
        total: total ?? this.total,
        shpStatus: shpStatus ?? this.shpStatus,
        productId: productId ?? this.productId,
        customerId: customerId ?? this.customerId,
        vehicleId: vehicleId ?? this.vehicleId,
        usrName: usrName ?? this.usrName,
        advanceAmount: advanceAmount ?? this.advanceAmount,
        remark: remark ?? this.remark
      );

  factory ShippingModel.fromMap(Map<String, dynamic> json) => ShippingModel(
    shpId: json["shpID"],
    vehicle: json["vehicle"],
    proName: json["proName"],
    customer: json["customer"],
    shpFrom: json["shpFrom"],
    shpMovingDate: json["shpMovingDate"] == null ? null : DateTime.parse(json["shpMovingDate"]),
    shpLoadSize: json["shpLoadSize"],
    shpUnit: json["shpUnit"],
    shpTo: json["shpTo"],
    shpArriveDate: json["shpArriveDate"] == null ? null : DateTime.parse(json["shpArriveDate"]),
    shpUnloadSize: json["shpUnloadSize"],
    shpRent: json["shpRent"],
    total: json["total"],
    perId: json["perID"],
    shpStatus: json["shpStatus"],
  );

  Map<String, dynamic> toMap() => {
    "shpID": shpId,
    "vehicle": vehicle,
    "proName": proName,
    "customer": customer,
    "shpFrom": shpFrom,
    "shpMovingDate": shpMovingDate?.toIso8601String(),
    "shpLoadSize": shpLoadSize,
    "shpUnit": shpUnit,
    "shpTo": shpTo,
    "shpArriveDate": shpArriveDate?.toIso8601String(),
    "shpUnloadSize": shpUnloadSize,
    "shpRent": shpRent,
    "total": total,
    "shpStatus": shpStatus,
    "shpCustomer": customerId,
    "shpVehicle": vehicleId,
    "shpProduct": productId,
    "usrName": usrName,
    "shpAdvance": advanceAmount,
    "shpRemark": remark,
  };
}
