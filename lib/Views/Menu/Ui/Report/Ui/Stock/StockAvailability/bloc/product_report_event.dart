part of 'product_report_bloc.dart';

sealed class ProductReportEvent extends Equatable {
  const ProductReportEvent();
}


class LoadProductsReportEvent extends ProductReportEvent{
  final int? productId;
  final int? storageId;
  final int? isNoStock;

  const LoadProductsReportEvent({this.productId, this.storageId, this.isNoStock});
  @override
  List<Object?> get props => [productId, storageId, isNoStock];
}

class ResetProductReportEvent extends ProductReportEvent{
  @override
  List<Object?> get props => [];
}