

import 'dart:convert';

AdjustmentModel adjustmentModelFromMap(String str) => AdjustmentModel.fromMap(json.decode(str));

String adjustmentModelToMap(AdjustmentModel data) => json.encode(data.toMap());

class AdjustmentModel {
  final int? ordId;
  final String? ordName;
  final int? ordPersonal;
  final String? ordPersonalName;
  final String? ordxRef;
  final String? ordTrnRef;
  final int? account;
  final String? amount;
  final String? trnStateText;
  final DateTime? ordEntryDate;
  final List<Record>? records;

  AdjustmentModel({
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
    this.records,
  });

  AdjustmentModel copyWith({
    int? ordId,
    String? ordName,
    int? ordPersonal,
    String? ordPersonalName,
    String? ordxRef,
    String? ordTrnRef,
    int? account,
    String? amount,
    String? trnStateText,
    DateTime? ordEntryDate,
    List<Record>? records,
  }) =>
      AdjustmentModel(
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
        records: records ?? this.records,
      );

  factory AdjustmentModel.fromMap(Map<String, dynamic> json) => AdjustmentModel(
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
    records: json["records"] == null ? [] : List<Record>.from(json["records"]!.map((x) => Record.fromMap(x))),
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
    "records": records == null ? [] : List<dynamic>.from(records!.map((x) => x.toMap())),
  };
}

class Record {
  final int? stkId;
  final int? stkProduct;
  final String? proName;
  final String? stkEntryType;
  final int? stkStorage;
  final String? stgName;
  final String? stkQuantity;
  final String? stkPurPrice;

  Record({
    this.stkId,
    this.stkProduct,
    this.proName,
    this.stkEntryType,
    this.stkStorage,
    this.stgName,
    this.stkQuantity,
    this.stkPurPrice,
  });

  Record copyWith({
    int? stkId,
    int? stkProduct,
    String? proName,
    String? stkEntryType,
    int? stkStorage,
    String? stgName,
    String? stkQuantity,
    String? stkPurPrice,
  }) =>
      Record(
        stkId: stkId ?? this.stkId,
        stkProduct: stkProduct ?? this.stkProduct,
        proName: proName ?? this.proName,
        stkEntryType: stkEntryType ?? this.stkEntryType,
        stkStorage: stkStorage ?? this.stkStorage,
        stgName: stgName ?? this.stgName,
        stkQuantity: stkQuantity ?? this.stkQuantity,
        stkPurPrice: stkPurPrice ?? this.stkPurPrice,
      );

  factory Record.fromMap(Map<String, dynamic> json) => Record(
    stkId: json["stkID"],
    stkProduct: json["stkProduct"],
    proName: json["proName"],
    stkEntryType: json["stkEntryType"],
    stkStorage: json["stkStorage"],
    stgName: json["stgName"],
    stkQuantity: json["stkQuantity"],
    stkPurPrice: json["stkPurPrice"],
  );

  Map<String, dynamic> toMap() => {
    "stkID": stkId,
    "stkProduct": stkProduct,
    "proName": proName,
    "stkEntryType": stkEntryType,
    "stkStorage": stkStorage,
    "stgName": stgName,
    "stkQuantity": stkQuantity,
    "stkPurPrice": stkPurPrice,
  };
}