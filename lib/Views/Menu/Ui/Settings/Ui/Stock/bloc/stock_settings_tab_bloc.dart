import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'stock_settings_tab_event.dart';
part 'stock_settings_tab_state.dart';

class StockSettingsTabBloc extends Bloc<StockSettingsTabEvent, StockSettingsTabState> {
  StockSettingsTabBloc() : super(StockSettingsTabState(tab: StockSettingsTabName.products)) {
    on<StockSettingsTabOnChangedEvent>((event, emit) {
       emit(StockSettingsTabState(tab: event.tab));
    });
  }
}
