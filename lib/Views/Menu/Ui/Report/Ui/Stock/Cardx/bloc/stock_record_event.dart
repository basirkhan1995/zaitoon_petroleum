part of 'stock_record_bloc.dart';

sealed class StockRecordEvent extends Equatable {
  const StockRecordEvent();
}


class LoadStockRecordEvent extends StockRecordEvent{
  final String? fromDate;
  final String? toDate;
  final int? productId;
  final int? storageId;
  final int? partyId;
  const LoadStockRecordEvent({this.fromDate, this.toDate, this.productId, this.storageId,this.partyId});
  @override
  List<Object?> get props => [fromDate, toDate, productId, storageId,partyId];
}

class ResetStockRecordEvent extends StockRecordEvent{
  @override
  List<Object?> get props => [];
}