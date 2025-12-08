part of 'driver_bloc.dart';

sealed class DriverState extends Equatable {
  const DriverState();
}

final class DriverInitial extends DriverState {
  @override
  List<Object> get props => [];
}

final class DriverLoadingState extends DriverState{
  @override
  List<Object> get props => [];
}


final class DriverErrorState extends DriverState{
  final String message;
  const DriverErrorState(this.message);
  @override
  List<Object> get props => [message];
}

final class DriverLoadedState extends DriverState{
  final List<DriverModel> drivers;
  const DriverLoadedState(this.drivers);
  @override
  List<Object> get props => [drivers];
}


