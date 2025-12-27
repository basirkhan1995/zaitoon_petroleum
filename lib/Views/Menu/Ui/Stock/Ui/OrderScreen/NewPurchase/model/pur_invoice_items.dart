
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