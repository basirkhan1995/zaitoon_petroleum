import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'user_profile_settings_event.dart';
part 'user_profile_settings_state.dart';

class UserProfileSettingsBloc extends Bloc<UserProfileSettingsEvent, UserProfileSettingsState> {
  UserProfileSettingsBloc() : super(UserProfileSettingsInitial()) {
    on<UserProfileSettingsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
