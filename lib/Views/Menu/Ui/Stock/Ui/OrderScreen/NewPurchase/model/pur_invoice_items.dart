
class PurInvoiceItem {
  final String rowId;
  String productId;
  String productName;
  int qty;
  double purPrice;
  int storageId;
  String storageName;
  PurInvoiceItem({
    String? itemId,
    required this.productId,
    required this.productName,
    required this.qty,
    required this.purPrice,
    required this.storageName,
    required this.storageId,
  }) : rowId = itemId ?? DateTime.now().millisecondsSinceEpoch.toString();

  double get total => qty * purPrice;
}

// PurchaseRecord model for API records
class PurchaseRecord {
  final int proID;
  final int stgID;
  final double quantity;
  final double pPrice;

  PurchaseRecord({
    required this.proID,
    required this.stgID,
    required this.quantity,
    required this.pPrice,
  });

  Map<String, dynamic> toJson() => {
    'proID': proID,
    'stgID': stgID,
    'quantity': quantity,
    'pPrice': pPrice,
  };
}