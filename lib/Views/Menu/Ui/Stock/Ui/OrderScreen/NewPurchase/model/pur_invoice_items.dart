
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

class PurchaseRecord {
  final int proID;
  final int stgID;
  final double quantity;
  final double? pPrice;
  final double? sPrice;

  PurchaseRecord({
    required this.proID,
    required this.stgID,
    required this.quantity,
    this.pPrice,
    this.sPrice,
  });

  Map<String, dynamic> toJson() => {
    'stkProduct': proID,
    'stkStorage': stgID,
    'stkQuantity': quantity,
    'stkPurPrice': pPrice,
    'stkSalePrice': sPrice,
  };
}