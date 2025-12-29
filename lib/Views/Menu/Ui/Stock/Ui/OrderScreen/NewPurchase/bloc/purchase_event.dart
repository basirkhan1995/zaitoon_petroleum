part of 'purchase_bloc.dart';

abstract class PurchaseEvent extends Equatable {
  const PurchaseEvent();

  @override
  List<Object?> get props => [];
}

class InitializePurchaseEvent extends PurchaseEvent {}

class SelectSupplierEvent extends PurchaseEvent {
  final IndividualsModel supplier;
  const SelectSupplierEvent(this.supplier);

  @override
  List<Object?> get props => [supplier];
}

class SelectSupplierAccountEvent extends PurchaseEvent {
  final AccountsModel supplier;
  const SelectSupplierAccountEvent(this.supplier);

  @override
  List<Object?> get props => [supplier];
}

class ClearSupplierEvent extends PurchaseEvent {}

class AddNewItemEvent extends PurchaseEvent {}

class RemoveItemEvent extends PurchaseEvent {
  final String rowId;
  const RemoveItemEvent(this.rowId);

  @override
  List<Object?> get props => [rowId];
}

class UpdateItemEvent extends PurchaseEvent {
  final String rowId;
  final String? productId;
  final String? productName;
  final int? qty;
  final double? purPrice;
  final int? storageId;
  final String? storageName;

  const UpdateItemEvent({
    required this.rowId,
    this.productId,
    this.productName,
    this.qty,
    this.purPrice,
    this.storageId,
    this.storageName,
  });

  @override
  List<Object?> get props => [
    rowId,
    productId,
    productName,
    qty,
    purPrice,
    storageId,
    storageName,
  ];
}

class UpdatePaymentEvent extends PurchaseEvent {
  final double payment;
  const UpdatePaymentEvent(this.payment);

  @override
  List<Object?> get props => [payment];
}

class ResetPurchaseEvent extends PurchaseEvent {}

class SavePurchaseInvoiceEvent extends PurchaseEvent {
  final String usrName;
  final int perID;
  final int? accNumber;
  final double? totalAmount;
  final double cashPayment;
  final String? xRef;
  final List<PurInvoiceItem> items;
  final Completer<String> completer;

  const SavePurchaseInvoiceEvent({
    required this.usrName,
    required this.perID,
    this.xRef,
    this.accNumber,
    this.totalAmount,
    required this.cashPayment,
    required this.items,
    required this.completer,
  });

  @override
  List<Object?> get props => [usrName, perID, xRef, items, completer, cashPayment];
}

class LoadStoragesEvent extends PurchaseEvent {
  final int productId;
  const LoadStoragesEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}