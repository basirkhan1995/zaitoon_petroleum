part of 'vehicle_bloc.dart';

sealed class VehicleEvent extends Equatable {
  const VehicleEvent();
}

class LoadVehicleEvent extends VehicleEvent{
  final int? vehicleId;
  const LoadVehicleEvent({this.vehicleId});
  @override
  List<Object?> get props => [vehicleId];
}

class AddVehicleEvent extends VehicleEvent{
  final VehicleModel newVehicle;
  const AddVehicleEvent(this.newVehicle);
  @override
  List<Object?> get props => [newVehicle];
}

class UpdateVehicleEvent extends VehicleEvent{
  final VehicleModel newVehicle;
  const UpdateVehicleEvent(this.newVehicle);
  @override
  List<Object?> get props => [newVehicle];
}

class LoadVehicleReportEvent extends VehicleEvent{
  final int regExpired;
  const LoadVehicleReportEvent(this.regExpired);
  @override
  List<Object?> get props => [regExpired];
}