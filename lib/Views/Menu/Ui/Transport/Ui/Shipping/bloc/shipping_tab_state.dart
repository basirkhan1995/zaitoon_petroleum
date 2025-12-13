part of 'shipping_tab_bloc.dart';

enum ShippingTabName {shipping, shippingExpense}

class ShippingTabState extends Equatable {
  final ShippingTabName tabs;
  const ShippingTabState({this.tabs = ShippingTabName.shipping});
  @override
  List<Object> get props => [tabs];
}