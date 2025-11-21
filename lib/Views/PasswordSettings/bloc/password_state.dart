part of 'password_bloc.dart';

sealed class PasswordState extends Equatable {
  const PasswordState();
}

final class PasswordInitial extends PasswordState {
  @override
  List<Object> get props => [];
}

final class PasswordErrorState extends PasswordState {
  final String message;
  const PasswordErrorState(this.message);
  @override
  List<Object> get props => [message];
}

final class PasswordLoadingState extends PasswordState {
  @override
  List<Object> get props => [];
}

final class PasswordResetSuccessState extends PasswordState {
  @override
  List<Object> get props => [];
}

