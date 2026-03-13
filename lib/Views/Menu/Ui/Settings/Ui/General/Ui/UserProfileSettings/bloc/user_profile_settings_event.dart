part of 'user_profile_settings_bloc.dart';

sealed class UserProfileSettingsEvent extends Equatable {
  const UserProfileSettingsEvent();
}

class LoadProfileSettingsEvent extends UserProfileSettingsEvent {
  final String usrName;
  const LoadProfileSettingsEvent(this.usrName);

  @override
  List<Object?> get props => [usrName];
}

class UpdateProfileSettingsEvent extends UserProfileSettingsEvent{
  @override
  List<Object?> get props => [];
}

class RefreshProfileEvent extends UserProfileSettingsEvent {
  final String usrName;
  const RefreshProfileEvent(this.usrName);

  @override
  List<Object?> get props => [usrName];
}