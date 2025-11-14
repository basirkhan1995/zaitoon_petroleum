part of 'stock_tab_bloc.dart';

enum StockTabsName {products, purchase, sell, returnedGoods, shift}

class StockTabState extends Equatable {
  final StockTabsName tabs;
   StockTabState({this.tabs = StockTabsName.products});
  @override
  List<Object> get props => [tabs];
}