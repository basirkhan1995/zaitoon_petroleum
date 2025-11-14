import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'stk_tab_event.dart';
part 'stk_tab_state.dart';

class StakeholderTabBloc extends Bloc<StakeholderTabEvent, StakeholderTabState> {
  StakeholderTabBloc() : super(StakeholderTabState(tab: StakeholderTabName.entities)) {
    on<StkOnChangedEvent>((event, emit) {
      emit(StakeholderTabState(tab: event.tab));
    });
  }
}
