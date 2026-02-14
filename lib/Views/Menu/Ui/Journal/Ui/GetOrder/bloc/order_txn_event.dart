part of 'order_txn_bloc.dart';

sealed class OrderTxnEvent extends Equatable {
  const OrderTxnEvent();
}

class FetchOrderTxnEvent extends OrderTxnEvent {
  final String reference;
  const FetchOrderTxnEvent({
    required this.reference,
  });
  @override
  List<Object> get props => [reference];
}