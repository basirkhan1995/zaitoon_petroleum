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


final class TxnLoadingState extends TransactionsState {
  @override
  List<Object> get props => [];
}

final class TxnCashLoadingState extends TransactionsState {
  @override
  List<Object> get props => [];
}

final class TxnUpdateLoadingState extends TransactionsState {
  @override
  List<Object> get props => [];
}

final class TxnDeleteLoadingState extends TransactionsState {
  @override
  List<Object> get props => [];
}

final class TxnAuthorizeLoadingState extends TransactionsState {
  @override
  List<Object> get props => [];
}

final class TxnReverseLoadingState extends TransactionsState {
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

