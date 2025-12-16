
part of 'shipping_bloc.dart';

abstract class ShippingEvent extends Equatable {
  const ShippingEvent();
}

// List operations
class LoadShippingEvent extends ShippingEvent {
  @override
  List<Object> get props => [];
}

class AddShippingEvent extends ShippingEvent {
  final ShippingModel newShipping;
  const AddShippingEvent(this.newShipping);

  @override
  List<Object> get props => [newShipping];
}

class UpdateShippingEvent extends ShippingEvent {
  final ShippingModel updatedShipping;
  const UpdateShippingEvent(this.updatedShipping);

  @override
  List<Object> get props => [updatedShipping];
}

// Detail operations
class LoadShippingDetailEvent extends ShippingEvent {
  final int shpId;
  const LoadShippingDetailEvent(this.shpId);

  @override
  List<Object> get props => [shpId];
}

class UpdateShippingDetailEvent extends ShippingEvent {
  final ShippingDetailsModel shipping;
  const UpdateShippingDetailEvent(this.shipping);

  @override
  List<Object> get props => [shipping];
}

// Stepper operations
class UpdateStepperStepEvent extends ShippingEvent {
  final int step;
  const UpdateStepperStepEvent(this.step);

  @override
  List<Object> get props => [step];
}

// This was missing - ADD THIS
class ClearShippingDetailEvent extends ShippingEvent {
  @override
  List<Object> get props => [];
}