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
  final int? perId;
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
  final String? shpRemark;
  final List<Pyment>? pyment;
  final List<Expense>? expenses;

  ShippingDetailsModel({
    this.shpId,
    this.vehicle,
    this.vclId,
    this.proName,
    this.proId,
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
    this.shpRemark,
    this.pyment,
    this.expenses,
  });

  ShippingDetailsModel copyWith({
    int? shpId,
    String? vehicle,
    int? vclId,
    String? proName,
    int? proId,
    int? perId,
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
    String? shpRemark,
    List<Pyment>? pyment,
    List<Expense>? expenses,
  }) =>
      ShippingDetailsModel(
        shpId: shpId ?? this.shpId,
        vehicle: vehicle ?? this.vehicle,
        vclId: vclId ?? this.vclId,
        proName: proName ?? this.proName,
        proId: proId ?? this.proId,
        perId: perId ?? this.perId,
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
        shpRemark: shpRemark ?? this.shpRemark,
        pyment: pyment ?? this.pyment,
        expenses: expenses ?? this.expenses,
      );

  factory ShippingDetailsModel.fromMap(Map<String, dynamic> json) => ShippingDetailsModel(
    shpId: json["shpID"],
    vehicle: json["vehicle"],
    vclId: json["vclID"],
    proName: json["proName"],
    proId: json["proID"],
    perId: json["perID"],
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
    shpRemark: json["shpRemark"],
    pyment: json["pyment"] == null ? [] : List<Pyment>.from(json["pyment"]!.map((x) => Pyment.fromMap(x))),
    expenses: json["expenses"] == null ? [] : List<Expense>.from(json["expenses"]!.map((x) => Expense.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "shpID": shpId,
    "vehicle": vehicle,
    "vclID": vclId,
    "proName": proName,
    "proID": proId,
    "perID": perId,
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
    "shpRemark": shpRemark,
    "pyment": pyment == null ? [] : List<dynamic>.from(pyment!.map((x) => x.toMap())),
    "expenses": expenses == null ? [] : List<dynamic>.from(expenses!.map((x) => x.toMap())),
  };
}

class Expense {
  final String? trdReference;
  final int? accNumber;
  final String? accName;
  final String? amount;
  final String? currency;
  final String? narration;

  Expense({
    this.trdReference,
    this.accNumber,
    this.accName,
    this.amount,
    this.currency,
    this.narration,
  });

  Expense copyWith({
    String? trdReference,
    int? accNumber,
    String? accName,
    String? amount,
    String? currency,
    String? narration,
  }) =>
      Expense(
        trdReference: trdReference ?? this.trdReference,
        accNumber: accNumber ?? this.accNumber,
        accName: accName ?? this.accName,
        amount: amount ?? this.amount,
        currency: currency ?? this.currency,
        narration: narration ?? this.narration,
      );

  factory Expense.fromMap(Map<String, dynamic> json) => Expense(
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

class Pyment {
  final String? trdReference;
  final String? cashAmount;
  final String? cardAmount;
  final int? accountCustomer;
  final String? accName;

  Pyment({
    this.trdReference,
    this.cashAmount,
    this.cardAmount,
    this.accountCustomer,
    this.accName,
  });

  Pyment copyWith({
    String? trdReference,
    String? cashAmount,
    String? cardAmount,
    int? accountCustomer,
    String? accName,
  }) =>
      Pyment(
        trdReference: trdReference ?? this.trdReference,
        cashAmount: cashAmount ?? this.cashAmount,
        cardAmount: cardAmount ?? this.cardAmount,
        accountCustomer: accountCustomer ?? this.accountCustomer,
        accName: accName ?? this.accName,
      );

  factory Pyment.fromMap(Map<String, dynamic> json) => Pyment(
    trdReference: json["trdReference"],
    cashAmount: json["cashAmount"],
    cardAmount: json["cardAmount"],
    accountCustomer: json["account_customer"],
    accName: json["accName"],
  );

  Map<String, dynamic> toMap() => {
    "trdReference": trdReference,
    "cashAmount": cashAmount,
    "cardAmount": cardAmount,
    "account_customer": accountCustomer,
    "accName": accName,
  };
}
