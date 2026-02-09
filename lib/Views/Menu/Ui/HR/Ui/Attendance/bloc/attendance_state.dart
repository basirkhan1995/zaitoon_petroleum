part of 'attendance_bloc.dart';

sealed class AttendanceState extends Equatable {
  const AttendanceState();
}

final class AttendanceInitial extends AttendanceState {
  @override
  List<Object> get props => [];
}

final class AttendanceLoadingState extends AttendanceState {
  @override
  List<Object?> get props => [];
}

final class AttendanceSilentLoadingState extends AttendanceState {
  final List<AttendanceRecord> attendance;
  const AttendanceSilentLoadingState(this.attendance);

  @override
  List<Object?> get props => [attendance];
}

final class AttendanceErrorState extends AttendanceState {
  final String message;
  const AttendanceErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

final class AttendanceLoadedState extends AttendanceState {
  final List<AttendanceRecord> attendance;
  const AttendanceLoadedState(this.attendance);

  @override
  List<Object?> get props => [attendance];
}

final class AttendanceSuccessState extends AttendanceState {
  final String message;
  const AttendanceSuccessState(this.message);

  @override
  List<Object?> get props => [message];
}
