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

class UpdateOrderItemEvent extends OrderByIdEvent {
  final int index;
  final double? quantity;
  final double? price;
  final int? storageId;

  const UpdateOrderItemEvent({
    required this.index,
    this.quantity,
    this.price,
    this.storageId,
  });

  @override
  List<Object?> get props => [index, quantity, price, storageId];
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

class ResetOrderEvent extends OrderByIdEvent {}

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