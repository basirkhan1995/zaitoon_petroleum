part of 'payroll_bloc.dart';

sealed class PayrollEvent extends Equatable {
  const PayrollEvent();
}

class LoadPayrollEvent extends PayrollEvent{
  final String date;
  const LoadPayrollEvent(this.date);
  @override
  List<Object?> get props => [date];
}

