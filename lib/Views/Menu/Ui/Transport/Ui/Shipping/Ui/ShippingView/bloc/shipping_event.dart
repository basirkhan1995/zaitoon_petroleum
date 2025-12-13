part of 'shipping_bloc.dart';

sealed class ShippingEvent extends Equatable {
  const ShippingEvent();
}

class AddShippingEvent extends ShippingEvent{
  final ShippingModel newShipping;
  const AddShippingEvent(this.newShipping);
  @override
  List<Object?> get props => [];
}

class UpdateShippingEvent extends ShippingEvent{
  final ShippingModel newShipping;
  const UpdateShippingEvent(this.newShipping);
  @override
  List<Object?> get props => [];
}

class LoadShippingEvent extends ShippingEvent{
  final int? shpId;
  const LoadShippingEvent({this.shpId});
  @override
  List<Object?> get props => [shpId];
}