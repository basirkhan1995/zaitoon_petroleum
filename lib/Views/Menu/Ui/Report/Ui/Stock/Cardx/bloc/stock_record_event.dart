part of 'stock_record_bloc.dart';

sealed class StockRecordEvent extends Equatable {
  const StockRecordEvent();
}


class LoadStockRecordEvent extends StockRecordEvent{
  final String? fromDate;
  final String? toDate;
  final int? productId;
  final int? storageId;
  const LoadStockRecordEvent({this.fromDate, this.toDate, this.productId, this.storageId});
  @override
  List<Object?> get props => [fromDate, toDate, productId, storageId];
}

class ResetStockRecordEvent extends StockRecordEvent{
  @override
  List<Object?> get props => [];
}