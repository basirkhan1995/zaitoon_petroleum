part of 'driver_bloc.dart';

sealed class DriverEvent extends Equatable {
  const DriverEvent();
}

class LoadDriverEvent extends DriverEvent{
  final int? empId;
  const LoadDriverEvent({this.empId});
  @override
  List<Object?> get props => [empId];
}
