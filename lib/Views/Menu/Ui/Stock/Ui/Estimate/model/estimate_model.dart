
class EstimateModel {
  final int? ordId;
  final String? ordName;
  final int? ordPersonal;
  final String? ordPersonalName;
  final int? ordBranch;
  final String? brcName;
  final String? ordxRef;
  final String? ordTrnRef;
  final String? total;
  final String? amount; // Credit amount
  final int? acc; // Account number
  final String? personal; // Customer name
  final int? perId; // Customer ID
  final DateTime? ordEntryDate;
  final String? trnStateText;
  final String? totalEstimate;
  final String? productName;
  final List<EstimateRecord>? records;

  EstimateModel({
    this.ordId,
    this.ordName,
    this.productName,
    this.ordPersonal,
    this.ordPersonalName,
    this.ordBranch,
    this.brcName,
    this.ordxRef,
    this.ordTrnRef,
    this.total,
    this.amount,
    this.acc,
    this.personal,
    this.perId,
    this.ordEntryDate,
    this.trnStateText,
    this.totalEstimate,
    this.records,
  });

  EstimateModel copyWith({
    int? ordId,
    String? ordName,
    String? productName,
    int? ordPersonal,
    String? ordPersonalName,
    int? ordBranch,
    String? brcName,
    String? ordxRef,
    String? ordTrnRef,
    String? total,
    String? amount,
    int? acc,
    String? personal,
    int? perId,
    DateTime? ordEntryDate,
    String? trnStateText,
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
        total: total ?? this.total,
        productName: productName ?? this.productName,
        amount: amount ?? this.amount,
        acc: acc ?? this.acc,
        personal: personal ?? this.personal,
        perId: perId ?? this.perId,
        ordEntryDate: ordEntryDate ?? this.ordEntryDate,
        trnStateText: trnStateText ?? this.trnStateText,
        records: records ?? this.records,
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
    total: json["total"],
    amount: json["amount"],
    acc: json["acc"],
    personal: json["personal"],
    productName: json["tstProductName"],
    perId: json["perID"],
    totalEstimate: json["total"],
    ordEntryDate: json["ordEntryDate"] != null
        ? DateTime.tryParse(json["ordEntryDate"])
        : null,
    trnStateText: json["trnStateText"],
    records: json["records"] == null
        ? []
        : List<EstimateRecord>.from(
        json["records"]!.map((x) => EstimateRecord.fromMap(x))),
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
    "total": total,
    "amount": amount,
    "tstProductName":productName,
    "acc": acc,
    "personal": personal,
    "perID": perId,
    "ordEntryDate": ordEntryDate?.toIso8601String(),
    "trnStateText": trnStateText,
    "records": records == null
        ? []
        : List<dynamic>.from(records!.map((x) => x.toMap())),
  };

  double get grandTotal {
    if (records == null) return 0.0;
    return records!.fold(0.0, (sum, record) {
      final qty = double.tryParse(record.tstQuantity ?? "0") ?? 0;
      final price = double.tryParse(record.tstSalePrice ?? "0") ?? 0;
      return sum + (qty * price);
    });
  }

  double get creditAmount => double.tryParse(amount ?? "0.0") ?? 0.0;
  double get cashPayment => grandTotal - creditAmount;

  PaymentMode get paymentMode {
    if (creditAmount <= 0) {
      return PaymentMode.cash;
    } else if (cashPayment <= 0) {
      return PaymentMode.credit;
    } else {
      return PaymentMode.mixed;
    }
  }

  bool get isPending => trnStateText?.toLowerCase() == 'pending';

  // ADD THESE NEW METHODS FOR PROFIT CALCULATION
  double get totalPurchaseCost {
    if (records == null) return 0.0;
    return records!.fold(0.0, (sum, record) {
      return sum + record.totalPurchase;
    });
  }

  double get totalSaleValue {
    if (records == null) return 0.0;
    return records!.fold(0.0, (sum, record) {
      return sum + record.total;
    });
  }

  double get totalProfit {
    return totalSaleValue - totalPurchaseCost;
  }

  double get profitPercentage {
    if (totalPurchaseCost == 0) return 0.0;
    return (totalProfit / totalPurchaseCost) * 100;
  }

  double get profitMarginPercentage {
    if (totalSaleValue == 0) return 0.0;
    return (totalProfit / totalSaleValue) * 100;
  }
}

class EstimateRecord {
  final int? tstId;
  final int? tstOrder;
  final int? tstProduct;
  final int? tstStorage;
  final String? tstQuantity;
  final String? productName;
  final String? tstPurPrice;
  final String? tstSalePrice;
  final String? storageName;

  EstimateRecord({
    this.tstId,
    this.tstOrder,
    this.storageName,
    this.tstProduct,
    this.tstStorage,
    this.productName,
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
    String? storageName,
    String? productName,
    String? tstSalePrice,
  }) =>
      EstimateRecord(
        tstId: tstId ?? this.tstId,
        tstOrder: tstOrder ?? this.tstOrder,
        tstProduct: tstProduct ?? this.tstProduct,
        storageName: storageName ?? this.storageName,
        tstStorage: tstStorage ?? this.tstStorage,
        tstQuantity: tstQuantity ?? this.tstQuantity,
        tstPurPrice: tstPurPrice ?? this.tstPurPrice,
        productName: productName ?? this.productName,
        tstSalePrice: tstSalePrice ?? this.tstSalePrice,
      );

  factory EstimateRecord.fromMap(Map<String, dynamic> json) => EstimateRecord(
    tstId: json["tstID"],
    tstOrder: json["tstOrder"],
    tstProduct: json["tstProduct"],
    tstStorage: json["tstStorage"],
    tstQuantity: json["tstQuantity"],
    storageName: json["tstStorageName"],
    tstPurPrice: json["tstPurPrice"],
    productName: json["tstProductName"],
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

  // ADD THESE GETTERS FOR CALCULATIONS
  double get quantity => double.tryParse(tstQuantity ?? "0") ?? 0;
  double get purchasePrice => double.tryParse(tstPurPrice ?? "0") ?? 0;
  double get salePrice => double.tryParse(tstSalePrice ?? "0") ?? 0;
  double get total => quantity * salePrice;
  double get totalPurchase => quantity * purchasePrice;
  double get profit => total - totalPurchase;
  double get profitPercentage {
    if (purchasePrice == 0) return 0.0;
    return ((salePrice - purchasePrice) / purchasePrice) * 100;
  }
  double get profitMargin {
    if (salePrice == 0) return 0.0;
    return ((salePrice - purchasePrice) / salePrice) * 100;
  }
}

enum PaymentMode { cash, credit, mixed }