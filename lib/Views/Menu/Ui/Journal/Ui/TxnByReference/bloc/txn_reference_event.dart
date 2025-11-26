part of 'txn_reference_bloc.dart';

sealed class TxnReferenceEvent extends Equatable {
  const TxnReferenceEvent();
}

class FetchTxnByReferenceEvent extends TxnReferenceEvent{
  final String reference;
  const FetchTxnByReferenceEvent(this.reference);
  @override
  List<Object?> get props => [reference];
}