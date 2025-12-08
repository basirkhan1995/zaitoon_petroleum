part of 'shipping_bloc.dart';

sealed class ShippingState extends Equatable {
  const ShippingState();
}

final class ShippingInitial extends ShippingState {
  @override
  List<Object> get props => [];
}
