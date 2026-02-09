part of 'attendance_bloc.dart';

sealed class AttendanceEvent extends Equatable {
  const AttendanceEvent();
}

class AddAttendanceEvent extends AttendanceEvent{
  final String usrName;
  final String checkIn;
  final String checkOut;
  final String date;
  const AddAttendanceEvent({required this.usrName, required this.checkIn, required this.checkOut,required this.date});
  @override
  List<Object?> get props => [usrName, checkIn, checkOut, date];
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