part of 'orders_bloc.dart';

sealed class OrdersEvent extends Equatable {
  const OrdersEvent();
}

class LoadOrdersEvent extends OrdersEvent{
  final int? orderId;
  const LoadOrdersEvent({this.orderId});
  @override
  List<Object?> get props => [orderId];
}


class PurchaseEvent extends OrdersEvent{
  @override
  List<Object?> get props => [];
}

class SaleEvent extends OrdersEvent{
  @override
  List<Object?> get props => [];
}

class EstimateEvent extends OrdersEvent{
  @override
  List<Object?> get props => [];
}

class ReturnGoodsEvent extends OrdersEvent{
  @override
  List<Object?> get props => [];
}

