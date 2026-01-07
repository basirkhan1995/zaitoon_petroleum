import 'dart:convert';

EstimateModel estimateModelFromMap(String str) => EstimateModel.fromMap(json.decode(str));

String estimateModelToMap(EstimateModel data) => json.encode(data.toMap());

class EstimateModel {
  final int? ordId;
  final String? ordName;
  final int? ordPersonal;
  final String? ordPersonalName;
  final int? ordBranch;
  final String? brcName;
  final String? ordxRef;
  final String? ordTrnRef;
  final String? totalEstimate;
  final List<EstimateRecord>? records;

  EstimateModel({
    this.ordId,
    this.ordName,
    this.ordPersonal,
    this.ordPersonalName,
    this.ordBranch,
    this.brcName,
    this.ordxRef,
    this.ordTrnRef,
    this.records,
    this.totalEstimate
  });

  EstimateModel copyWith({
    int? ordId,
    String? ordName,
    int? ordPersonal,
    String? ordPersonalName,
    int? ordBranch,
    String? brcName,
    String? ordxRef,
    String? ordTrnRef,
    String? totalEstimate,
    List<EstimateRecord>? records,
  }) =>
      EstimateModel(
        ordId: ordId ?? this.ordId,
        ordName: ordName ?? this.ordName,
        ordPersonal: ordPersonal ?? this.ordPersonal,
        ordPersonalName: ordPersonalName ?? this.ordPersonalName,
        ordBranch: ordBranch ?? this.ordBranch,
        brcName: brcName ?? this.brcName,
        ordxRef: ordxRef ?? this.ordxRef,
        ordTrnRef: ordTrnRef ?? this.ordTrnRef,
        records: records ?? this.records,
        totalEstimate: totalEstimate ?? this.totalEstimate
      );

  factory EstimateModel.fromMap(Map<String, dynamic> json) => EstimateModel(
    ordId: json["ordID"],
    ordName: json["ordName"],
    ordPersonal: json["ordPersonal"],
    ordPersonalName: json["ordPersonalName"],
    ordBranch: json["ordBranch"],
    brcName: json["brcName"],
    ordxRef: json["ordxRef"],
    ordTrnRef: json["ordTrnRef"],
    totalEstimate: json["total"],
    records: json["records"] == null ? [] : List<EstimateRecord>.from(json["records"]!.map((x) => EstimateRecord.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "ordID": ordId,
    "ordName": ordName,
    "ordPersonal": ordPersonal,
    "ordPersonalName": ordPersonalName,
    "ordBranch": ordBranch,
    "brcName": brcName,
    "ordxRef": ordxRef,
    "ordTrnRef": ordTrnRef,
    "records": records == null ? [] : List<dynamic>.from(records!.map((x) => x.toMap())),
  };
}

class EstimateRecord {
  final int? tstId;
  final int? tstOrder;
  final int? tstProduct;
  final int? tstStorage;
  final String? tstQuantity;
  final String? tstPurPrice;
  final String? tstSalePrice;

  EstimateRecord({
    this.tstId,
    this.tstOrder,
    this.tstProduct,
    this.tstStorage,
    this.tstQuantity,
    this.tstPurPrice,
    this.tstSalePrice,
  });

  EstimateRecord copyWith({
    int? tstId,
    int? tstOrder,
    int? tstProduct,
    int? tstStorage,
    String? tstQuantity,
    String? tstPurPrice,
    String? tstSalePrice,
  }) =>
      EstimateRecord(
        tstId: tstId ?? this.tstId,
        tstOrder: tstOrder ?? this.tstOrder,
        tstProduct: tstProduct ?? this.tstProduct,
        tstStorage: tstStorage ?? this.tstStorage,
        tstQuantity: tstQuantity ?? this.tstQuantity,
        tstPurPrice: tstPurPrice ?? this.tstPurPrice,
        tstSalePrice: tstSalePrice ?? this.tstSalePrice,
      );

  factory EstimateRecord.fromMap(Map<String, dynamic> json) => EstimateRecord(
    tstId: json["tstID"],
    tstOrder: json["tstOrder"],
    tstProduct: json["tstProduct"],
    tstStorage: json["tstStorage"],
    tstQuantity: json["tstQuantity"],
    tstPurPrice: json["tstPurPrice"],
    tstSalePrice: json["tstSalePrice"],
  );

  Map<String, dynamic> toMap() => {
    "tstID": tstId,
    "tstOrder": tstOrder,
    "tstProduct": tstProduct,
    "tstStorage": tstStorage,
    "tstQuantity": tstQuantity,
    "tstPurPrice": tstPurPrice,
    "tstSalePrice": tstSalePrice,
  };
}
