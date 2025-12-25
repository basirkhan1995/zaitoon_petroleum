part of 'stock_tab_bloc.dart';

enum StockTabsName {estimates, orders, shift}

class StockTabState extends Equatable {
  final StockTabsName tabs;
   const StockTabState({this.tabs = StockTabsName.estimates});
  @override
  List<Object> get props => [tabs];
}