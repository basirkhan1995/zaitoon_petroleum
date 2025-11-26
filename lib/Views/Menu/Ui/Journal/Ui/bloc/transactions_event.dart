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

class LoadAllTransactionsEvent extends TransactionsEvent {
  final String status;
  const LoadAllTransactionsEvent(this.status);
  @override
  List<Object?> get props => [status];
}

class LoadAuthorizedTransactionsEvent extends TransactionsEvent {
  final String status;
  const LoadAuthorizedTransactionsEvent(this.status);
  @override
  List<Object?> get props => [status];
}

class LoadPendingTransactionsEvent extends TransactionsEvent {
  final String status;
  const LoadPendingTransactionsEvent(this.status);
  @override
  List<Object?> get props => [status];
}

class AuthorizeTxnEvent extends TransactionsEvent {
  final String reference;
  final String usrName;
  const AuthorizeTxnEvent({required this.reference,required this.usrName});
  @override
  List<Object?> get props => [reference, usrName];
}

class ReverseTxnEvent extends TransactionsEvent {
  @override
  List<Object?> get props => [];
}