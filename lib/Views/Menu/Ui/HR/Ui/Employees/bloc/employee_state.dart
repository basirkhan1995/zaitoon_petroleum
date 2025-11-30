part of 'employee_bloc.dart';

sealed class EmployeeState extends Equatable {
  const EmployeeState();
}

final class EmployeeInitial extends EmployeeState {
  @override
  List<Object> get props => [];
}

final class EmployeeLoadedState extends EmployeeState {
  final List<EmployeeModel> employees;
  const EmployeeLoadedState(this.employees);
  @override
  List<Object> get props => [];
}

final class EmployeeLoadingState extends EmployeeState {
  @override
  List<Object> get props => [];
}

final class EmployeeSuccessState extends EmployeeState {
  @override
  List<Object> get props => [];
}

final class EmployeeErrorState extends EmployeeState {
  final String message;
  const EmployeeErrorState(this.message);
  @override
  List<Object> get props => [message];
}
