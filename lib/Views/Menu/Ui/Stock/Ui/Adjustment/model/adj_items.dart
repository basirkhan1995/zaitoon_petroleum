// adj_items.dart
import '../model/adjustment_model.dart';

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

  factory AdjustmentItem.empty() => AdjustmentItem(
    productId: '',
    productName: '',
    quantity: 1,
    purPrice: 0,
    storageName: '',
    storageId: 0,
  );

  factory AdjustmentItem.fromRecord(Record record) => AdjustmentItem(
    itemId: record.stkId?.toString(),
    productId: record.stkProduct?.toString() ?? '',
    productName: record.proName ?? '',
    quantity: double.tryParse(record.stkQuantity ?? '0') ?? 0,
    purPrice: double.tryParse(record.stkPurPrice ?? '0') ?? 0,
    storageId: record.stkStorage ?? 0,
    storageName: record.stgName ?? '',
  );

  AdjustmentItem copyWith({
    String? productId,
    String? productName,
    double? quantity,
    double? purPrice,
    int? storageId,
    String? storageName,
  }) {
    return AdjustmentItem(
      itemId: rowId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      purPrice: purPrice ?? this.purPrice,
      storageName: storageName ?? this.storageName,
      storageId: storageId ?? this.storageId,
    );
  }

  double get totalCost => quantity * (purPrice ?? 0);

  Map<String, dynamic> toRecordMap() {
    return {
      'stkProduct': int.tryParse(productId) ?? 0,
      'stkStorage': storageId,
      'stkQuantity': quantity,
      'stkPurPrice': purPrice,
    };
  }
}