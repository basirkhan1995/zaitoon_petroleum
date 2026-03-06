import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'permission_settings_event.dart';
part 'permission_settings_state.dart';

class PermissionSettingsBloc extends Bloc<PermissionSettingsEvent, PermissionSettingsState> {
  PermissionSettingsBloc() : super(PermissionSettingsInitial()) {
    on<PermissionSettingsEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
