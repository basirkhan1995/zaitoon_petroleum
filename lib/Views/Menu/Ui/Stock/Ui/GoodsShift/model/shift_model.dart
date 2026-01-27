// To parse this JSON data, do
//
//     final goodShiftModel = goodShiftModelFromMap(jsonString);

import 'dart:convert';

List<GoodShiftModel> goodShiftModelFromMap(String str) => List<GoodShiftModel>.from(json.decode(str).map((x) => GoodShiftModel.fromMap(x)));

String goodShiftModelToMap(List<GoodShiftModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

class GoodShiftModel {
  final int? ordId;
  final String? ordName;
  final dynamic ordPersonal;
  final dynamic ordPersonalName;
  final dynamic ordxRef;
  final String? ordTrnRef;
  final int? account;
  final String? amount;
  final String? trnStateText;
  final DateTime? ordEntryDate;

  GoodShiftModel({
    this.ordId,
    this.ordName,
    this.ordPersonal,
    this.ordPersonalName,
    this.ordxRef,
    this.ordTrnRef,
    this.account,
    this.amount,
    this.trnStateText,
    this.ordEntryDate,
  });

  GoodShiftModel copyWith({
    int? ordId,
    String? ordName,
    dynamic ordPersonal,
    dynamic ordPersonalName,
    dynamic ordxRef,
    String? ordTrnRef,
    int? account,
    String? amount,
    String? trnStateText,
    DateTime? ordEntryDate,
  }) =>
      GoodShiftModel(
        ordId: ordId ?? this.ordId,
        ordName: ordName ?? this.ordName,
        ordPersonal: ordPersonal ?? this.ordPersonal,
        ordPersonalName: ordPersonalName ?? this.ordPersonalName,
        ordxRef: ordxRef ?? this.ordxRef,
        ordTrnRef: ordTrnRef ?? this.ordTrnRef,
        account: account ?? this.account,
        amount: amount ?? this.amount,
        trnStateText: trnStateText ?? this.trnStateText,
        ordEntryDate: ordEntryDate ?? this.ordEntryDate,
      );

  factory GoodShiftModel.fromMap(Map<String, dynamic> json) => GoodShiftModel(
    ordId: json["ordID"],
    ordName: json["ordName"],
    ordPersonal: json["ordPersonal"],
    ordPersonalName: json["ordPersonalName"],
    ordxRef: json["ordxRef"],
    ordTrnRef: json["ordTrnRef"],
    account: json["account"],
    amount: json["amount"],
    trnStateText: json["trnStateText"],
    ordEntryDate: json["ordEntryDate"] == null ? null : DateTime.parse(json["ordEntryDate"]),
  );

  Map<String, dynamic> toMap() => {
    "ordID": ordId,
    "ordName": ordName,
    "ordPersonal": ordPersonal,
    "ordPersonalName": ordPersonalName,
    "ordxRef": ordxRef,
    "ordTrnRef": ordTrnRef,
    "account": account,
    "amount": amount,
    "trnStateText": trnStateText,
    "ordEntryDate": ordEntryDate?.toIso8601String(),
  };
}
// shift_record_model.dart
class ShiftRecord {
  final int? stkProduct;
  final int? fromStorage;
  final int? toStorage;
  final String? stkQuantity;
  final String? stkPurPrice;

  ShiftRecord({
    this.stkProduct,
    this.fromStorage,
    this.toStorage,
    this.stkQuantity,
    this.stkPurPrice,
  });

  ShiftRecord copyWith({
    int? stkProduct,
    int? fromStorage,
    int? toStorage,
    String? stkQuantity,
    String? stkPurPrice,
  }) => ShiftRecord(
    stkProduct: stkProduct ?? this.stkProduct,
    fromStorage: fromStorage ?? this.fromStorage,
    toStorage: toStorage ?? this.toStorage,
    stkQuantity: stkQuantity ?? this.stkQuantity,
    stkPurPrice: stkPurPrice ?? this.stkPurPrice,
  );

  factory ShiftRecord.fromMap(Map<String, dynamic> json) => ShiftRecord(
    stkProduct: json["stkProduct"],
    fromStorage: json["fromStorage"],
    toStorage: json["toStorage"],
    stkQuantity: json["stkQuantity"],
    stkPurPrice: json["stkPurPrice"],
  );

  Map<String, dynamic> toMap() => {
    "stkProduct": stkProduct,
    "fromStorage": fromStorage,
    "toStorage": toStorage,
    "stkQuantity": stkQuantity,
    "stkPurPrice": stkPurPrice,
  };

  double get quantity => double.tryParse(stkQuantity ?? "0") ?? 0;
  double get purchasePrice => double.tryParse(stkPurPrice ?? "0") ?? 0;
  double get totalValue => quantity * purchasePrice;
}