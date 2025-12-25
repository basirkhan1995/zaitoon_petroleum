part of 'stock_settings_tab_bloc.dart';

sealed class StockSettingsTabEvent extends Equatable {
  const StockSettingsTabEvent();
}

class StockSettingsTabOnChangedEvent extends StockSettingsTabEvent{
  final StockSettingsTabName tab;
  const StockSettingsTabOnChangedEvent(this.tab);
  @override
  List<Object?> get props => [tab];
}