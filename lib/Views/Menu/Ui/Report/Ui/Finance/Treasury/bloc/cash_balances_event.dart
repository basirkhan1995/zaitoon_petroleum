// cash_balances_event.dart
part of 'cash_balances_bloc.dart';

sealed class CashBalancesEvent extends Equatable {
  const CashBalancesEvent();
}

class LoadCashBalancesEvent extends CashBalancesEvent {
  final int? branchId;
  const LoadCashBalancesEvent({this.branchId});
  @override
  List<Object?> get props => [branchId];
}

class LoadAllCashBalancesEvent extends CashBalancesEvent {
  const LoadAllCashBalancesEvent();
  @override
  List<Object> get props => [];
}