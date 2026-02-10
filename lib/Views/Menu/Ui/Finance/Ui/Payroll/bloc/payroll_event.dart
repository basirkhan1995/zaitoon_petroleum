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

class PostPayrollEvent extends PayrollEvent {
  final String usrName;
  final List<PayrollModel> records;
  const PostPayrollEvent(this.usrName, this.records);
  @override
  List<Object?> get props => [usrName, records];
}