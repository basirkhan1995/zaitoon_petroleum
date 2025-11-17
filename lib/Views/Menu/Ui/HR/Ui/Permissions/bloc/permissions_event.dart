part of 'permissions_bloc.dart';

sealed class PermissionsEvent extends Equatable {
  const PermissionsEvent();
}

class LoadPermissionsEvent extends PermissionsEvent{
  final String usrName;
  const LoadPermissionsEvent(this.usrName);
  @override
  List<Object?> get props => [usrName];
}

class UpdatePermissionsStatusEvent extends PermissionsEvent{
  final String usrName;
  final int usrId;
  final int uprRole;
  final bool uprStatus;
  const UpdatePermissionsStatusEvent({required this.uprStatus, required this.usrId, required this.uprRole, required this.usrName});
  @override
  List<Object?> get props => [uprStatus, usrId, uprRole,usrName];
}

