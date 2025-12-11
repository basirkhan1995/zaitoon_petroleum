import 'dart:convert';

ShippingModel shippingModelFromMap(String str) => ShippingModel.fromMap(json.decode(str));

String shippingModelToMap(ShippingModel data) => json.encode(data.toMap());

class ShippingModel {
  final int? shpProduct;
  final int? shpVehicle;
  final int? shpCustomer;
  final String? shpFrom;
  final DateTime? shpMovingDate;
  final String? shpTo;
  final DateTime? shpArriveDate;
  final String? shpLoadSize;
  final String? shpUnloadSize;
  final String? shpUnit;
  final String? shpRent;

  ShippingModel({
    this.shpProduct,
    this.shpVehicle,
    this.shpCustomer,
    this.shpFrom,
    this.shpMovingDate,
    this.shpTo,
    this.shpArriveDate,
    this.shpLoadSize,
    this.shpUnloadSize,
    this.shpUnit,
    this.shpRent,
  });

  ShippingModel copyWith({
    int? shpProduct,
    int? shpVehicle,
    int? shpCustomer,
    String? shpFrom,
    DateTime? shpMovingDate,
    String? shpTo,
    DateTime? shpArriveDate,
    String? shpLoadSize,
    String? shpUnloadSize,
    String? shpUnit,
    String? shpRent,
  }) =>
      ShippingModel(
        shpProduct: shpProduct ?? this.shpProduct,
        shpVehicle: shpVehicle ?? this.shpVehicle,
        shpCustomer: shpCustomer ?? this.shpCustomer,
        shpFrom: shpFrom ?? this.shpFrom,
        shpMovingDate: shpMovingDate ?? this.shpMovingDate,
        shpTo: shpTo ?? this.shpTo,
        shpArriveDate: shpArriveDate ?? this.shpArriveDate,
        shpLoadSize: shpLoadSize ?? this.shpLoadSize,
        shpUnloadSize: shpUnloadSize ?? this.shpUnloadSize,
        shpUnit: shpUnit ?? this.shpUnit,
        shpRent: shpRent ?? this.shpRent,
      );

  factory ShippingModel.fromMap(Map<String, dynamic> json) => ShippingModel(
    shpProduct: json["shpProduct"],
    shpVehicle: json["shpVehicle"],
    shpCustomer: json["shpCustomer"],
    shpFrom: json["shpFrom"],
    shpMovingDate: json["shpMovingDate"] == null ? null : DateTime.parse(json["shpMovingDate"]),
    shpTo: json["shpTo"],
    shpArriveDate: json["shpArriveDate"] == null ? null : DateTime.parse(json["shpArriveDate"]),
    shpLoadSize: json["shpLoadSize"],
    shpUnloadSize: json["shpUnloadSize"],
    shpUnit: json["shpUnit"],
    shpRent: json["shpRent"],
  );

  Map<String, dynamic> toMap() => {
    "shpProduct": shpProduct,
    "shpVehicle": shpVehicle,
    "shpCustomer": shpCustomer,
    "shpFrom": shpFrom,
    "shpMovingDate": "${shpMovingDate!.year.toString().padLeft(4, '0')}-${shpMovingDate!.month.toString().padLeft(2, '0')}-${shpMovingDate!.day.toString().padLeft(2, '0')}",
    "shpTo": shpTo,
    "shpArriveDate": "${shpArriveDate!.year.toString().padLeft(4, '0')}-${shpArriveDate!.month.toString().padLeft(2, '0')}-${shpArriveDate!.day.toString().padLeft(2, '0')}",
    "shpLoadSize": shpLoadSize,
    "shpUnloadSize": shpUnloadSize,
    "shpUnit": shpUnit,
    "shpRent": shpRent,
  };
}
