part of 'transactions_bloc.dart';

sealed class TransactionsState extends Equatable {
  const TransactionsState();
}

final class TransactionsInitial extends TransactionsState {
  @override
  List<Object> get props => [];
}

final class TransactionSuccessState extends TransactionsState {
  @override
  List<Object> get props => [];
}


final class TransactionLoadingState extends TransactionsState {
  @override
  List<Object> get props => [];
}


final class TransactionErrorState extends TransactionsState {
  final String message;
  const TransactionErrorState(this.message);
  @override
  List<Object> get props => [message];
}

final class TransactionLoadedState extends TransactionsState {
  final List<TransactionsModel> txn;
  const TransactionLoadedState(this.txn);
  @override
  List<Object> get props => [txn];
}

