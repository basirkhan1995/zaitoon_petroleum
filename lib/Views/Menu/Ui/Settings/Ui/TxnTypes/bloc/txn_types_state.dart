part of 'txn_types_bloc.dart';

sealed class TxnTypesState extends Equatable {
  const TxnTypesState();
}

final class TxnTypesInitial extends TxnTypesState {
  @override
  List<Object> get props => [];
}
