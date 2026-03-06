part of 'user_profile_settings_bloc.dart';

sealed class UserProfileSettingsState extends Equatable {
  const UserProfileSettingsState();
}

final class UserProfileSettingsInitial extends UserProfileSettingsState {
  @override
  List<Object> get props => [];
}
