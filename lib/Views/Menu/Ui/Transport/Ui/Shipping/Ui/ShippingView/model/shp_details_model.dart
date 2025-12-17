// To parse this JSON data, do
//
//     final shippingDetailsModel = shippingDetailsModelFromMap(jsonString);

import 'dart:convert';

ShippingDetailsModel shippingDetailsModelFromMap(String str) => ShippingDetailsModel.fromMap(json.decode(str));

String shippingDetailsModelToMap(ShippingDetailsModel data) => json.encode(data.toMap());

class ShippingDetailsModel {
  final int? shpId;
  final String? vehicle;
  final int? vclId;
  final String? proName;
  final int? proId;
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
  final List<ShippingExpenseModel>? income;
  final List<ShippingExpenseModel>? expenses;

  ShippingDetailsModel({
    this.shpId,
    this.vehicle,
    this.vclId,
    this.proName,
    this.proId,
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
    this.income,
    this.expenses,
  });

  ShippingDetailsModel copyWith({
    int? shpId,
    String? vehicle,
    int? vclId,
    String? proName,
    int? proId,
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
    List<ShippingExpenseModel>? income,
    List<ShippingExpenseModel>? expenses,
  }) =>
      ShippingDetailsModel(
        shpId: shpId ?? this.shpId,
        vehicle: vehicle ?? this.vehicle,
        vclId: vclId ?? this.vclId,
        proName: proName ?? this.proName,
        proId: proId ?? this.proId,
        customer: customer ?? this.customer,
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
        income: income ?? this.income,
        expenses: expenses ?? this.expenses,
      );

  factory ShippingDetailsModel.fromMap(Map<String, dynamic> json) => ShippingDetailsModel(
    shpId: json["shpID"],
    vehicle: json["vehicle"],
    vclId: json["vclID"],
    proName: json["proName"],
    proId: json["proID"],
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
    shpStatus: json["shpStatus"],
    income: json["income"] == null ? [] : List<ShippingExpenseModel>.from(json["income"]!.map((x) => ShippingExpenseModel.fromMap(x))),
    expenses: json["expenses"] == null ? [] : List<ShippingExpenseModel>.from(json["expenses"]!.map((x) => ShippingExpenseModel.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "shpID": shpId,
    "vehicle": vehicle,
    "vclID": vclId,
    "proName": proName,
    "proID": proId,
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
    "income": income == null ? [] : List<dynamic>.from(income!.map((x) => x.toMap())),
    "expenses": expenses == null ? [] : List<dynamic>.from(expenses!.map((x) => x.toMap())),
  };
}

class ShippingExpenseModel {
  final String? trdReference;
  final int? accNumber;
  final String? accName;
  final String? amount;
  final String? currency;
  final String? narration;

  ShippingExpenseModel({
    this.trdReference,
    this.accNumber,
    this.accName,
    this.amount,
    this.currency,
    this.narration,
  });

  ShippingExpenseModel copyWith({
    String? trdReference,
    int? accNumber,
    String? accName,
    String? amount,
    String? currency,
    String? narration,
  }) =>
      ShippingExpenseModel(
        trdReference: trdReference ?? this.trdReference,
        accNumber: accNumber ?? this.accNumber,
        accName: accName ?? this.accName,
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
        narration: narration ?? this.narration,
      );

  factory ShippingExpenseModel.fromMap(Map<String, dynamic> json) => ShippingExpenseModel(
    trdReference: json["trdReference"],
    accNumber: json["accNumber"],
    accName: json["accName"],
    amount: json["amount"],
    currency: json["currency"],
    narration: json["narration"],
  );

  Map<String, dynamic> toMap() => {
    "trdReference": trdReference,
    "accNumber": accNumber,
    "accName": accName,
    "amount": amount,
    "currency": currency,
    "narration": narration,
  };
}
