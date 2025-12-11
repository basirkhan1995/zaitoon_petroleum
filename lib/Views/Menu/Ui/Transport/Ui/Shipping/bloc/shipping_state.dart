part of 'shipping_bloc.dart';

sealed class ShippingState extends Equatable {
  const ShippingState();
}

final class ShippingInitial extends ShippingState {
  @override
  List<Object> get props => [];
}

final class ShippingLoadingState extends ShippingState {
  @override
  List<Object> get props => [];
}

final class ShippingErrorState extends ShippingState {
  final String error;
  const ShippingErrorState(this.error);
  @override
  List<Object> get props => [error];
}

final class ShippingSuccessState extends ShippingState {
  @override
  List<Object> get props => [];
}

final class ShippingLoadedState extends ShippingState {
  final List<ShippingModel> shipping;
  const ShippingLoadedState(this.shipping);
  @override
  List<Object> get props => [shipping];
}