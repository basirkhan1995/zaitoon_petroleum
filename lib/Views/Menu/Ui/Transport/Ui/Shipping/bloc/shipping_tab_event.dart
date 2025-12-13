part of 'shipping_tab_bloc.dart';

sealed class ShippingTabEvent extends Equatable {
  const ShippingTabEvent();
}

class ShippingOnchangeEvent extends ShippingTabEvent{
  final ShippingTabName tab;
  const ShippingOnchangeEvent(this.tab);
  @override
  List<Object?> get props => [tab];
}