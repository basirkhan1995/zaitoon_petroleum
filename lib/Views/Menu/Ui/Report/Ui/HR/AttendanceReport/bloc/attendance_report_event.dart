part of 'attendance_report_bloc.dart';

sealed class AttendanceReportEvent extends Equatable {
  const AttendanceReportEvent();
}

class LoadAttendanceReportEvent extends AttendanceReportEvent{
  final String? fromDate;
  final String? toDate;
  final int? empId;
  final int? status;
  const LoadAttendanceReportEvent({this.fromDate, this.toDate, this.empId, this.status});
  @override
  List<Object?> get props => [fromDate, toDate, empId, status];
}

class ResetAttendanceReportEvent extends AttendanceReportEvent{
  @override
  List<Object?> get props => [];
}