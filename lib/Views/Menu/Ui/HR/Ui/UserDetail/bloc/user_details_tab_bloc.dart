import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'user_details_tab_event.dart';
part 'user_details_tab_state.dart';

class UserDetailsTabBloc extends Bloc<UserDetailsTabEvent, UserDetailsTabState> {
  UserDetailsTabBloc() : super(UserDetailsTabInitial()) {
    on<UserDetailsTabEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
