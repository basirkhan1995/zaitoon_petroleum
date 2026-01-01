part of 'purchase_invoice_bloc.dart';

abstract class PurchaseInvoiceEvent extends Equatable {
  const PurchaseInvoiceEvent();

  @override
  List<Object?> get props => [];
}

class InitializePurchaseInvoiceEvent extends PurchaseInvoiceEvent {}

class SelectSupplierEvent extends PurchaseInvoiceEvent {
  final IndividualsModel supplier;
  const SelectSupplierEvent(this.supplier);

  @override
  List<Object?> get props => [supplier];
}

class SelectSupplierAccountEvent extends PurchaseInvoiceEvent {
  final AccountsModel supplier;
  const SelectSupplierAccountEvent(this.supplier);

  @override
  List<Object?> get props => [supplier];
}

class ClearSupplierEvent extends PurchaseInvoiceEvent {}

class AddNewPurchaseItemEvent extends PurchaseInvoiceEvent {}

class RemovePurchaseItemEvent extends PurchaseInvoiceEvent {
  final String rowId;
  const RemovePurchaseItemEvent(this.rowId);

  @override
  List<Object?> get props => [rowId];
}

class UpdatePurchaseItemEvent extends PurchaseInvoiceEvent {
  final String rowId;
  final String? productId;
  final String? productName;
  final int? qty;
  final double? purPrice;
  final double? salePrice;
  final int? storageId;
  final String? storageName;

  const UpdatePurchaseItemEvent({
    required this.rowId,
    this.productId,
    this.productName,
    this.qty,
    this.purPrice,
    this.salePrice,
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
    salePrice,
    storageId,
    storageName,
  ];
}

class UpdatePurchasePaymentEvent extends PurchaseInvoiceEvent {
  final double payment;
  const UpdatePurchasePaymentEvent(this.payment);

  @override
  List<Object?> get props => [payment];
}

class ResetPurchaseInvoiceEvent extends PurchaseInvoiceEvent {}

class SavePurchaseInvoiceEvent extends PurchaseInvoiceEvent {
  final String usrName;
  final String orderName;
  final int ordPersonal;
  final double cashPayment;
  final String? xRef;
  final List<PurchaseInvoiceItem> items;
  final Completer<String> completer;

  const SavePurchaseInvoiceEvent({
    required this.usrName,
    required this.ordPersonal,
    required this.orderName,
    this.xRef,
    required this.cashPayment,
    required this.items,
    required this.completer,
  });

  @override
  List<Object?> get props => [usrName, ordPersonal, xRef, cashPayment, items, completer];
}

class LoadPurchaseStoragesEvent extends PurchaseInvoiceEvent {
  final int productId;
  const LoadPurchaseStoragesEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}