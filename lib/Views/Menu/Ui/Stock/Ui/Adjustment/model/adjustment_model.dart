import 'dart:convert';

List<AdjustmentModel> adjustmentModelFromMap(String str) => List<AdjustmentModel>.from(json.decode(str).map((x) => AdjustmentModel.fromMap(x)));

String adjustmentModelToMap(List<AdjustmentModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toMap())));

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
