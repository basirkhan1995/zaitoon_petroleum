part of 'stock_tab_bloc.dart';

sealed class StockTabEvent extends Equatable {
  const StockTabEvent();
}
class StockOnChangeEvent extends StockTabEvent{
  final StockTabsName tab;
  const StockOnChangeEvent(this.tab);
  @override
  List<Object?> get props => [tab];
}