part of 'attendance_report_bloc.dart';

sealed class AttendanceReportState extends Equatable {
  const AttendanceReportState();
}

final class AttendanceReportInitial extends AttendanceReportState {
  @override
  List<Object> get props => [];
}


final class AttendanceReportLoadedState extends AttendanceReportState {
  final List<AttendanceReportModel> attendance;
  const AttendanceReportLoadedState(this.attendance);
  @override
  List<Object> get props => [attendance];
}

final class AttendanceReportLoadingState extends AttendanceReportState {
  @override
  List<Object> get props => [];
}

final class AttendanceReportErrorState extends AttendanceReportState {
  final String? error;
  const AttendanceReportErrorState(this.error);
  @override
  List<Object> get props => [];
}


