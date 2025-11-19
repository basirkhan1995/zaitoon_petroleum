import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'user_details_tab_event.dart';
part 'user_details_tab_state.dart';

class UserDetailsTabBloc extends Bloc<UserDetailsTabEvent, UserDetailsTabState> {
  UserDetailsTabBloc() : super(UserDetailsTabState(tab: UserDetailsTabNames.overview)) {
    on<UserDetailsTabOnChangedEvent>((event, emit) {
      emit(UserDetailsTabState(tab: event.tab));
    });
  }
}
