part of 'permission_settings_bloc.dart';

sealed class PermissionSettingsState extends Equatable {
  const PermissionSettingsState();
}

final class PermissionSettingsInitial extends PermissionSettingsState {
  @override
  List<Object> get props => [];
}
