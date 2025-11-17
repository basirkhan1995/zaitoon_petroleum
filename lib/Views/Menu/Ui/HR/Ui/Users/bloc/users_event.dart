part of 'users_bloc.dart';

sealed class UsersEvent extends Equatable {
  const UsersEvent();
}

class LoadUsersEvent extends UsersEvent{
  final String? usrName;
  const LoadUsersEvent({this.usrName});

  @override
  List<Object?> get props => [usrName];
}