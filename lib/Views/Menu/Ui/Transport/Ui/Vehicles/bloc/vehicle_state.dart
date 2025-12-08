part of 'vehicle_bloc.dart';

sealed class VehicleState extends Equatable {
  const VehicleState();
}

final class VehicleInitial extends VehicleState {
  @override
  List<Object> get props => [];
}

final class VehicleLoadingState extends VehicleState {
  @override
  List<Object> get props => [];
}

final class VehicleSuccessState extends VehicleState {
  @override
  List<Object> get props => [];
}


final class VehicleErrorState extends VehicleState {
  final String message;
  const VehicleErrorState(this.message);
  @override
  List<Object> get props => [message];
}

final class VehicleLoadedState extends VehicleState {
  final List<VehicleModel> vehicles;
  const VehicleLoadedState(this.vehicles);
  @override
  List<Object> get props => [vehicles];
}
