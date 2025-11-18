part of 'permissions_bloc.dart';

sealed class PermissionsState extends Equatable {
  const PermissionsState();
}

final class PermissionsInitial extends PermissionsState {
  @override
  List<Object> get props => [];
}

final class PermissionsLoadingState extends PermissionsState {
  @override
  List<Object> get props => [];
}

final class PermissionsErrorState extends PermissionsState {
  final String message;
  const PermissionsErrorState(this.message);
  @override
  List<Object> get props => [message];
}

final class PermissionsSuccessState extends PermissionsState {
  @override
  List<Object> get props => [];
}

final class PermissionsLoadedState extends PermissionsState {
  final List<UserPermissionsModel> permissions;
  const PermissionsLoadedState(this.permissions);
  @override
  List<Object> get props => [permissions];
}


