part of 'payroll_bloc.dart';

sealed class PayrollState extends Equatable {
  const PayrollState();

  // Add this getter to all states
  List<PayrollModel> get payroll => [];
}

final class PayrollInitial extends PayrollState {
  @override
  List<Object> get props => [];
}

final class PayrollLoadingState extends PayrollState {
  @override
  List<Object?> get props => [];
}

final class PayrollSilentLoadingState extends PayrollState {
  final List<PayrollModel> attendance;
  const PayrollSilentLoadingState(this.attendance);

  @override
  List<PayrollModel> get payroll => attendance; // Add this

  @override
  List<Object?> get props => [attendance];
}

final class PayrollErrorState extends PayrollState {
  final String message;
  const PayrollErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

final class PayrollLoadedState extends PayrollState {
  @override
  final List<PayrollModel> payroll;
  const PayrollLoadedState(this.payroll);

  @override
  List<Object?> get props => [payroll];
}

final class PayrollSuccessState extends PayrollState {
  final String message;
  const PayrollSuccessState(this.message);

  @override
  List<Object?> get props => [message];
}