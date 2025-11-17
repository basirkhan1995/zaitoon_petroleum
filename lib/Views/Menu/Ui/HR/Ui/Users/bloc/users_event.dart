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