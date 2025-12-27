part of 'order_by_id_bloc.dart';

sealed class OrderByIdState extends Equatable {
  const OrderByIdState();
}

final class OrderByIdInitial extends OrderByIdState {
  @override
  List<Object> get props => [];
}
