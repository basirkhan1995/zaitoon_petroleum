part of 'order_txn_bloc.dart';

sealed class OrderTxnState extends Equatable {
  const OrderTxnState();
}

final class OrderTxnInitial extends OrderTxnState {
  @override
  List<Object> get props => [];
}

final class OrderTxnLoadingState extends OrderTxnState {
  @override
  List<Object> get props => [];
}

final class OrderTxnLoadedState extends OrderTxnState {
  final OrderTxnModel data;

  const OrderTxnLoadedState({required this.data});

  @override
  List<Object> get props => [data];
}

final class OrderTxnErrorState extends OrderTxnState {
  final String message;

  const OrderTxnErrorState({required this.message});

  @override
  List<Object> get props => [message];
}