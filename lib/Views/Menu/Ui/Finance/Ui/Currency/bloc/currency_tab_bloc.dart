import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'currency_tab_event.dart';
part 'currency_tab_state.dart';

class CurrencyTabBloc extends Bloc<CurrencyTabEvent, CurrencyTabState> {
  CurrencyTabBloc() : super(CurrencyTabState(tabs: CurrencyTabName.currency)) {

    on<CcyOnChangedEvent>((event, emit) {
      emit(CurrencyTabState(tabs: event.tab));
    });
  }
}
