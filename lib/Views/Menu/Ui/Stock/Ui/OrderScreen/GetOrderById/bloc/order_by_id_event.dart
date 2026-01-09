part of 'order_by_id_bloc.dart';

abstract class OrderByIdEvent extends Equatable {
  const OrderByIdEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrderByIdEvent extends OrderByIdEvent {
  final int orderId;

  const LoadOrderByIdEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class ToggleEditModeEvent extends OrderByIdEvent {}

class SelectOrderSupplierEvent extends OrderByIdEvent {
  final IndividualsModel supplier;

  const SelectOrderSupplierEvent(this.supplier);

  @override
  List<Object?> get props => [supplier];
}

class SelectOrderAccountEvent extends OrderByIdEvent {
  final AccountsModel account;

  const SelectOrderAccountEvent(this.account);

  @override
  List<Object?> get props => [account];
}

class ClearOrderAccountEvent extends OrderByIdEvent {}

class UpdateOrderPaymentEvent extends OrderByIdEvent {
  final double cashPayment;
  final double creditAmount;

  const UpdateOrderPaymentEvent({
    required this.cashPayment,
    required this.creditAmount,
  });

  @override
  List<Object?> get props => [cashPayment, creditAmount];
}

// Add to OrderByIdEvent part
class UnAuthorizeOrderTxnEvent extends OrderByIdEvent {
  final String usrName;
  final String reference;

  const UnAuthorizeOrderTxnEvent({
    required this.usrName,
    required this.reference,
  });

  @override
  List<Object?> get props => [usrName, reference];
}

class OrderByIdUnAuthorizing extends OrderByIdState {
  final OrderByIdModel order;

  const OrderByIdUnAuthorizing(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderByIdUnAuthorized extends OrderByIdState {
  final bool success;
  final String message;

  const OrderByIdUnAuthorized(this.success, {this.message = ''});

  @override
  List<Object?> get props => [success, message];
}


class UpdateSaleOrderItemEvent extends OrderByIdEvent {
  final int index;
  final int productId;
  final String productName;
  final int? storageId;
  final double purchasePrice;
  final double salePrice;
  final double? quantity;

  const UpdateSaleOrderItemEvent({
    required this.index,
    required this.productId,
    required this.productName,
    this.storageId,
    required this.purchasePrice,
    required this.salePrice,
    this.quantity,
  });

  @override
  List<Object?> get props => [index, productId, productName, storageId, purchasePrice, salePrice, quantity];
}

class UpdateOrderItemEvent extends OrderByIdEvent {
  final int index;
  final int? productId;
  final String? productName;
  final double? quantity;
  final double? price;
  final int? storageId;
  final bool isPurchasePrice; // Add this flag

  const UpdateOrderItemEvent({
    required this.index,
    this.productId,
    this.productName,
    this.quantity,
    this.price,
    this.storageId,
    this.isPurchasePrice = false, // Default to false
  });

  @override
  List<Object?> get props => [index, productId, productName, quantity, price, storageId, isPurchasePrice];
}
class AddOrderItemEvent extends OrderByIdEvent {}

class RemoveOrderItemEvent extends OrderByIdEvent {
  final int index;

  const RemoveOrderItemEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class SaveOrderChangesEvent extends OrderByIdEvent {
  final String usrName;
  final Completer<bool> completer;

  const SaveOrderChangesEvent({
    required this.usrName,
    required this.completer,
  });

  @override
  List<Object?> get props => [usrName, completer];
}



class DeleteOrderEvent extends OrderByIdEvent {
  final int orderId;
  final String ref;
  final String orderName;
  final String usrName;

  const DeleteOrderEvent({
    required this.orderId,
    required this.ref,
    required this.orderName,
    required this.usrName,
  });

  @override
  List<Object?> get props => [orderId, ref, orderName, usrName];
}