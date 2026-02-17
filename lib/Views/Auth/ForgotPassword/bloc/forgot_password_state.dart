part of 'forgot_password_bloc.dart';

sealed class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object> get props => [];
}

final class ForgotPasswordInitial extends ForgotPasswordState {}

final class ForgotPasswordLoadingState extends ForgotPasswordState {}

// Email/Identity verification states
final class IdentityVerifiedState extends ForgotPasswordState {
  final String email;
  final String timeLimit;

  const IdentityVerifiedState({required this.email, required this.timeLimit});

  @override
  List<Object> get props => [email, timeLimit];
}

final class IdentityNotFoundState extends ForgotPasswordState {
  final String message;

  const IdentityNotFoundState({required this.message});

  @override
  List<Object> get props => [message];
}

// OTP verification states
final class OtpVerifiedState extends ForgotPasswordState {
  final String usrName;
  final String usrEmail;
  final String fullName;
  final String rstExpiry;
  final int rstStatus;

  const OtpVerifiedState({
    required this.usrName,
    required this.usrEmail,
    required this.fullName,
    required this.rstExpiry,
    required this.rstStatus,
  });

  @override
  List<Object> get props => [usrName, usrEmail, fullName, rstExpiry, rstStatus];
}

final class OtpInvalidState extends ForgotPasswordState {
  final String message;

  const OtpInvalidState({required this.message});

  @override
  List<Object> get props => [message];
}

final class OtpExpiredState extends ForgotPasswordState {
  final String message;

  const OtpExpiredState({required this.message});

  @override
  List<Object> get props => [message];
}

// Password reset states
final class PasswordResetSuccessState extends ForgotPasswordState {
  final String message;

  const PasswordResetSuccessState({required this.message});

  @override
  List<Object> get props => [message];
}

final class PasswordResetFailedState extends ForgotPasswordState {
  final String message;

  const PasswordResetFailedState({required this.message});

  @override
  List<Object> get props => [message];
}

// Error state
final class ForgotPasswordErrorState extends ForgotPasswordState {
  final String message;

  const ForgotPasswordErrorState({required this.message});

  @override
  List<Object> get props => [message];
}