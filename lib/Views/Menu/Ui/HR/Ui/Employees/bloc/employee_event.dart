part of 'employee_bloc.dart';

sealed class EmployeeEvent extends Equatable {
  const EmployeeEvent();
}


class LoadEmployeeEvent extends EmployeeEvent{
  final int? empId;
  const LoadEmployeeEvent({this.empId});
  @override
  List<Object?> get props => [empId];
}

class AddEmployeeEvent extends EmployeeEvent{
  final EmployeeModel newEmployee;
  const AddEmployeeEvent(this.newEmployee);
  @override
  List<Object?> get props => [newEmployee];
}