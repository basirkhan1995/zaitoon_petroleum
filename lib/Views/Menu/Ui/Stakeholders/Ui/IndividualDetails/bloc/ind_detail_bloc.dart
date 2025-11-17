import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'ind_detail_event.dart';
part 'ind_detail_state.dart';

class IndividualDetailTabBloc extends Bloc<IndDetailTabEvent, IndividualDetailTabState> {
  IndividualDetailTabBloc() : super(IndividualDetailTabState(tab: IndividualDetailTabName.accounts)) {
    on<IndOnChangedEvent>((event, emit) {
      emit(IndividualDetailTabState(tab: event.tab));
    });
  }
}
