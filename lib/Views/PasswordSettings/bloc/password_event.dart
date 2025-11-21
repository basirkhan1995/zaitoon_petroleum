part of 'password_bloc.dart';

sealed class PasswordEvent extends Equatable {
  const PasswordEvent();
}

class ChangePasswordEvent extends PasswordEvent{
  final String oldPassword;
  final String newPassword;
  final String usrName;
  const ChangePasswordEvent({required this.oldPassword, required this.newPassword, required this.usrName});
  @override
  List<Object?> get props => [];
}

class ForceChangePasswordEvent extends PasswordEvent{
  final String newPassword;
  final String usrName;
  const ForceChangePasswordEvent({required this.usrName, required this.newPassword});
  @override
  List<Object?> get props => [newPassword, usrName];
}