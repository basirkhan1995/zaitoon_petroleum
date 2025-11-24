part of 'transactions_bloc.dart';

sealed class TransactionsEvent extends Equatable {
  const TransactionsEvent();
}

class OnCashTransactionEvent extends TransactionsEvent{
  final TransactionsModel transaction;
  const OnCashTransactionEvent(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

