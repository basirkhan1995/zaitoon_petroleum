part of 'txn_reference_bloc.dart';

sealed class TxnReferenceState extends Equatable {
  const TxnReferenceState();
}

final class TxnReferenceInitial extends TxnReferenceState {
  @override
  List<Object> get props => [];
}

final class TxnReferenceLoadingState extends TxnReferenceState {
  @override
  List<Object> get props => [];
}

final class TxnReferenceLoadedState extends TxnReferenceState{
  final TxnByReferenceModel transaction;
  const TxnReferenceLoadedState(this.transaction);
  @override
  List<Object> get props => [transaction];
}

final class TxnReferenceErrorState extends TxnReferenceState{
  final String error;
  const TxnReferenceErrorState(this.error);
  @override
  List<Object> get props => [error];
}