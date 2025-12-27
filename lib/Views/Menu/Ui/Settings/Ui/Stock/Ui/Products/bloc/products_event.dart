part of 'products_bloc.dart';

sealed class ProductsEvent extends Equatable {
  const ProductsEvent();
}

class LoadProductsEvent extends ProductsEvent{
  final int? proId;
  const LoadProductsEvent({this.proId});
  @override
  List<Object?> get props => [];
}

class LoadProductsStockEvent extends ProductsEvent{
  final int? proId;
  const LoadProductsStockEvent({this.proId});
  @override
  List<Object?> get props => [];
}

class AddProductEvent extends ProductsEvent{
  final ProductsModel newProduct;
  const AddProductEvent(this.newProduct);
  @override
  List<Object?> get props => [newProduct];
}

class UpdateProductEvent extends ProductsEvent{
  final ProductsModel newProduct;
  const UpdateProductEvent(this.newProduct);
  @override
  List<Object?> get props => [newProduct];
}

class DeleteProductEvent extends ProductsEvent{
  final int proId;
  const DeleteProductEvent(this.proId);
  @override
  List<Object?> get props => [proId];
}
