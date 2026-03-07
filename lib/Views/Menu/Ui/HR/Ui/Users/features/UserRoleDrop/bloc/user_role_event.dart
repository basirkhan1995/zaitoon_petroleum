part of 'user_role_bloc.dart';

sealed class UserRoleEvent extends Equatable {
  const UserRoleEvent();
}

class LoadUserRolesEvent extends UserRoleEvent{
  @override
  List<Object?> get props => [];
}

class AddUserRoleEvent extends UserRoleEvent {
  final String usrName;
  final String roleName;
  const AddUserRoleEvent({required this.usrName, required this.roleName});
  @override
  List<Object> get props => [usrName, roleName];
}

class UpdateUserRoleEvent extends UserRoleEvent {
  final String usrName;
  final String roleName;
  const UpdateUserRoleEvent({required this.usrName, required this.roleName});
  @override
  List<Object> get props => [usrName, roleName];
}
