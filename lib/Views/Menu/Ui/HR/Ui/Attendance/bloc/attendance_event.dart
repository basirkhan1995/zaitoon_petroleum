part of 'attendance_bloc.dart';

sealed class AttendanceEvent extends Equatable {
  const AttendanceEvent();
}

class AddAttendanceEvent extends AttendanceEvent{
  final AttendanceModel newData;
  const AddAttendanceEvent(this.newData);
  @override
  List<Object?> get props => [newData];
}
class LoadAllAttendanceEvent extends AttendanceEvent{
  final String? date;
  const LoadAllAttendanceEvent({this.date});
  @override
  List<Object?> get props => [date];
}

class UpdateAttendanceEvent extends AttendanceEvent{
  final AttendanceModel newData;
  const UpdateAttendanceEvent(this.newData);
  @override
  List<Object?> get props => [newData];
}