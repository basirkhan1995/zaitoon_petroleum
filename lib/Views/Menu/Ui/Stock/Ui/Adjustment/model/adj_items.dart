class AdjustmentItem {
  final String rowId;
  String productId;
  String productName;
  double quantity;
  double? purPrice;
  int storageId;
  String storageName;

  AdjustmentItem({
    String? itemId,
    required this.productId,
    required this.productName,
    required this.quantity,
    this.purPrice,
    required this.storageName,
    required this.storageId,
  }) : rowId = itemId ?? DateTime.now().millisecondsSinceEpoch.toString();

  double get totalCost => quantity * (purPrice ?? 0);
}

class AdjustmentRecord {
  final int stkProduct;
  final int stkStorage;
  final double stkQuantity;
  final double stkPurPrice;

  AdjustmentRecord({
    required this.stkProduct,
    required this.stkStorage,
    required this.stkQuantity,
    required this.stkPurPrice,
  });

  Map<String, dynamic> toJson() => {
    'stkProduct': stkProduct,
    'stkStorage': stkStorage,
    'stkQuantity': stkQuantity,
    'stkPurPrice': stkPurPrice,
  };
}