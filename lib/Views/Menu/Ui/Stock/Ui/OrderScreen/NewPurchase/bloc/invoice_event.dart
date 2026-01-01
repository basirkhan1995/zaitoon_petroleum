part of 'invoice_bloc.dart';

abstract class InvoiceEvent extends Equatable {
  const InvoiceEvent();

  @override
  List<Object?> get props => [];
}

class InitializeInvoiceEvent extends InvoiceEvent {}

class SelectSupplierEvent extends InvoiceEvent {
  final IndividualsModel supplier;
  const SelectSupplierEvent(this.supplier);

  @override
  List<Object?> get props => [supplier];
}

class SelectSupplierAccountEvent extends InvoiceEvent {
  final AccountsModel supplier;
  const SelectSupplierAccountEvent(this.supplier);

  @override
  List<Object?> get props => [supplier];
}

class ClearSupplierEvent extends InvoiceEvent {}

class AddNewItemEvent extends InvoiceEvent {}

class RemoveItemEvent extends InvoiceEvent {
  final String rowId;
  const RemoveItemEvent(this.rowId);

  @override
  List<Object?> get props => [rowId];
}

class UpdateItemEvent extends InvoiceEvent {
  final String rowId;
  final String? productId;
  final String? productName;
  final int? qty;
  final double? purPrice;
  final double? salePrice;
  final int? storageId;
  final String? storageName;

  const UpdateItemEvent({
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

class UpdatePaymentEvent extends InvoiceEvent {
  final double payment;
  const UpdatePaymentEvent(this.payment);

  @override
  List<Object?> get props => [payment];
}

class ResetInvoiceEvent extends InvoiceEvent {}

class SaveInvoiceEvent extends InvoiceEvent {
  final String usrName;
  final String orderName;
  final int ordPersonal;
  final double cashPayment;
  final String? xRef;
  final List<InvoiceItem> items;
  final Completer<String> completer;

  const SaveInvoiceEvent({
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

class LoadStoragesEvent extends InvoiceEvent {
  final int productId;
  const LoadStoragesEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}