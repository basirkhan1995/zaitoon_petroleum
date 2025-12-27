// To parse this JSON data, do
//
//     final orderByIdModel = orderByIdModelFromMap(jsonString);

import 'dart:convert';

OrderByIdModel orderByIdModelFromMap(String str) => OrderByIdModel.fromMap(json.decode(str));

String orderByIdModelToMap(OrderByIdModel data) => json.encode(data.toMap());

class OrderByIdModel {
  final int? ordId;
  final String? ordName;
  final int? perId;
  final String? personal;
  final String? ordxRef;
  final String? ordTrnRef;
  final int? acc;
  final String? amount;
  final String? trnStateText;
  final DateTime? ordEntryDate;
  final List<Record>? records;

  OrderByIdModel({
    this.ordId,
    this.ordName,
    this.perId,
    this.personal,
    this.ordxRef,
    this.ordTrnRef,
    this.acc,
    this.amount,
    this.trnStateText,
    this.ordEntryDate,
    this.records,
  });

  OrderByIdModel copyWith({
    int? ordId,
    String? ordName,
    int? perId,
    String? personal,
    String? ordxRef,
    String? ordTrnRef,
    int? acc,
    String? amount,
    String? trnStateText,
    DateTime? ordEntryDate,
    List<Record>? records,
  }) =>
      OrderByIdModel(
        ordId: ordId ?? this.ordId,
        ordName: ordName ?? this.ordName,
        perId: perId ?? this.perId,
        personal: personal ?? this.personal,
        ordxRef: ordxRef ?? this.ordxRef,
        ordTrnRef: ordTrnRef ?? this.ordTrnRef,
        acc: acc ?? this.acc,
        amount: amount ?? this.amount,
        trnStateText: trnStateText ?? this.trnStateText,
        ordEntryDate: ordEntryDate ?? this.ordEntryDate,
        records: records ?? this.records,
      );

  factory OrderByIdModel.fromMap(Map<String, dynamic> json) => OrderByIdModel(
    ordId: json["ordID"],
    ordName: json["ordName"],
    perId: json["perID"],
    personal: json["personal"],
    ordxRef: json["ordxRef"],
    ordTrnRef: json["ordTrnRef"],
    acc: json["acc"],
    amount: json["amount"],
    trnStateText: json["trnStateText"],
    ordEntryDate: json["ordEntryDate"] == null ? null : DateTime.parse(json["ordEntryDate"]),
    records: json["records"] == null ? [] : List<Record>.from(json["records"]!.map((x) => Record.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "ordID": ordId,
    "ordName": ordName,
    "perID": perId,
    "personal": personal,
    "ordxRef": ordxRef,
    "ordTrnRef": ordTrnRef,
    "acc": acc,
    "amount": amount,
    "trnStateText": trnStateText,
    "ordEntryDate": ordEntryDate?.toIso8601String(),
    "records": records == null ? [] : List<dynamic>.from(records!.map((x) => x.toMap())),
  };
}

class Record {
  final int? stkId;
  final int? stkOrder;
  final int? stkProduct;
  final String? stkEntryType;
  final int? stkStorage;
  final DateTime? stkExpiryDate;
  final String? stkQuantity;
  final String? stkPurPrice;
  final String? stkSalePrice;

  Record({
    this.stkId,
    this.stkOrder,
    this.stkProduct,
    this.stkEntryType,
    this.stkStorage,
    this.stkExpiryDate,
    this.stkQuantity,
    this.stkPurPrice,
    this.stkSalePrice,
  });

  Record copyWith({
    int? stkId,
    int? stkOrder,
    int? stkProduct,
    String? stkEntryType,
    int? stkStorage,
    DateTime? stkExpiryDate,
    String? stkQuantity,
    String? stkPurPrice,
    String? stkSalePrice,
  }) =>
      Record(
        stkId: stkId ?? this.stkId,
        stkOrder: stkOrder ?? this.stkOrder,
        stkProduct: stkProduct ?? this.stkProduct,
        stkEntryType: stkEntryType ?? this.stkEntryType,
        stkStorage: stkStorage ?? this.stkStorage,
        stkExpiryDate: stkExpiryDate ?? this.stkExpiryDate,
        stkQuantity: stkQuantity ?? this.stkQuantity,
        stkPurPrice: stkPurPrice ?? this.stkPurPrice,
        stkSalePrice: stkSalePrice ?? this.stkSalePrice,
      );

  factory Record.fromMap(Map<String, dynamic> json) => Record(
    stkId: json["stkID"],
    stkOrder: json["stkOrder"],
    stkProduct: json["stkProduct"],
    stkEntryType: json["stkEntryType"],
    stkStorage: json["stkStorage"],
    stkExpiryDate: json["stkExpiryDate"] == null ? null : DateTime.parse(json["stkExpiryDate"]),
    stkQuantity: json["stkQuantity"],
    stkPurPrice: json["stkPurPrice"],
    stkSalePrice: json["stkSalePrice"],
  );

  Map<String, dynamic> toMap() => {
    "stkID": stkId,
    "stkOrder": stkOrder,
    "stkProduct": stkProduct,
    "stkEntryType": stkEntryType,
    "stkStorage": stkStorage,
    "stkExpiryDate": stkExpiryDate?.toIso8601String(),
    "stkQuantity": stkQuantity,
    "stkPurPrice": stkPurPrice,
    "stkSalePrice": stkSalePrice,
  };
}
