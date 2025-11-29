part of 'users_bloc.dart';

sealed class UsersEvent extends Equatable {
  const UsersEvent();
}

class LoadUsersEvent extends UsersEvent{
  final int? usrOwner;
  const LoadUsersEvent({this.usrOwner});

  @override
  List<Object?> get props => [usrOwner];
}

class AddUserEvent extends UsersEvent{
  final UsersModel newUser;
  const AddUserEvent(this.newUser);
  @override
  List<Object?> get props => [newUser];
}

class UpdateUserEvent extends UsersEvent{
  final UsersModel newUser;
  const UpdateUserEvent(this.newUser);
  @override
  List<Object?> get props => [newUser];
}