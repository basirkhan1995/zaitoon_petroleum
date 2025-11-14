import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'stock_tab_event.dart';
part 'stock_tab_state.dart';

class StockTabBloc extends Bloc<StockTabEvent, StockTabState> {
  StockTabBloc() : super(StockTabState(tabs: StockTabsName.products)) {
    on<StockOnChangeEvent>((event, emit) {
      emit(StockTabState(tabs: event.tab));
    });
  }
}
