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

class UpdatePermissionsEvent extends PermissionsEvent {
  final String usrName;
  final int usrId;
  final List<Map<String, dynamic>> permissions;

  const UpdatePermissionsEvent({
    required this.usrName,
    required this.usrId,
    required this.permissions,
  });

  @override
  List<Object?> get props => [usrName, usrId, permissions];
}

