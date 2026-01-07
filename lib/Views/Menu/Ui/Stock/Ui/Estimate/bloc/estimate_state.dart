part of 'estimate_bloc.dart';

sealed class EstimateState extends Equatable {
  const EstimateState();
}

final class EstimateInitial extends EstimateState {
  @override
  List<Object> get props => [];
}
final class EstimateLoadingState extends EstimateState {
  @override
  List<Object> get props => [];
}

final class OrdersErrorState extends EstimateState {
  final String message;
  const OrdersErrorState(this.message);
  @override
  List<Object> get props => [message];
}


final class EstimateLoadedState extends EstimateState {
  final List<EstimateModel> order;
  const EstimateLoadedState(this.order);
  @override
  List<Object> get props => [order];
}