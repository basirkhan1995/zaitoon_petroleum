part of 'trial_balance_bloc.dart';

sealed class TrialBalanceEvent extends Equatable {
  const TrialBalanceEvent();
}

class LoadTrialBalanceEvent extends TrialBalanceEvent{
  final String currency;
  final String date;
  const LoadTrialBalanceEvent({required this.currency, required this.date});
  @override
  List<Object?> get props => [currency,date];
}