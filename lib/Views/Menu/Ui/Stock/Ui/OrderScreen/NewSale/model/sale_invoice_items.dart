
class SaleInvoiceItem {
  final String rowId;
  String productId;
  String productName;
  int qty;
  double? purPrice;
  double? salePrice;
  int storageId;
  String storageName;
  SaleInvoiceItem({
    String? itemId,
    required this.productId,
    required this.productName,
    required this.qty,
    this.purPrice,
    this.salePrice,
    required this.storageName,
    required this.storageId,
  }) : rowId = itemId ?? DateTime.now().millisecondsSinceEpoch.toString();

  double get totalPurchase => qty * (purPrice ?? 0);
  double get totalSale => qty * (salePrice ?? 0);
}
class SaleInvoiceRecord {
  final int proID;
  final int stgID;
  final double quantity;
  final double? pPrice;
  final double? sPrice;

  SaleInvoiceRecord({
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