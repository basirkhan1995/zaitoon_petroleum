part of 'forgot_password_bloc.dart';

sealed class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object> get props => [];
}

// Request password reset (send email/username)
class RequestResetEvent extends ForgotPasswordEvent {
  final String identity;

  const RequestResetEvent({required this.identity});

  @override
  List<Object> get props => [identity];
}

// Verify OTP
class VerifyOtpEvent extends ForgotPasswordEvent {
  final String otp;
  final String email;

  const VerifyOtpEvent({required this.otp, required this.email});

  @override
  List<Object> get props => [otp, email];
}

// Reset password with new password
class ResetPasswordEvent extends ForgotPasswordEvent {
  final String usrName;
  final String usrPass;
  final int? otp;

  const ResetPasswordEvent({
    required this.usrName,
    required this.usrPass,
    this.otp,
  });

  @override
  List<Object> get props => [usrName, usrPass];
}

// Resend OTP
class ResendOtpEvent extends ForgotPasswordEvent {
  final String identity;

  const ResendOtpEvent({required this.identity});

  @override
  List<Object> get props => [identity];
}

// Reset state
class ResetForgotPasswordStateEvent extends ForgotPasswordEvent {}