import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Attendance/model/attendance_model.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final Repositories _repo;

  String? _currentDate;
  List<AttendanceRecord>? _cachedAttendance;

  AttendanceBloc(this._repo) : super(AttendanceInitial()) {
    on<LoadAllAttendanceEvent>((event, emit) async {
      // Only show loading if it's initial load or date changed
      if (state is AttendanceInitial ||
          state is AttendanceErrorState ||
          _currentDate != event.date) {
        emit(AttendanceLoadingState());
      } else {
        // Silent loading - maintain current state
        emit(AttendanceSilentLoadingState(
           _cachedAttendance ?? []
        ));
      }

      try {
        final res = await _repo.getAllAttendance(date: event.date);
        _currentDate = event.date;
        _cachedAttendance = res;
        emit(AttendanceLoadedState(res));
      } catch (e) {
        emit(AttendanceErrorState(e.toString()));
      }
    });

    on<AddAttendanceEvent>((event, emit) async {
      // Keep current UI (silent loading)
      if (_cachedAttendance != null) {
        emit(AttendanceSilentLoadingState(_cachedAttendance!));
      }

      try {
        final res = await _repo.addNewAttendance(usrName: event.usrName, checkIn: event.checkIn, checkOut: event.checkOut, date: event.date);
        final msg = res["msg"];

        if (msg == "success") {
          // Reload attendance for the same date
          add(LoadAllAttendanceEvent(date: _currentDate));
        }
        else if (msg == "exit") {
          emit(const AttendanceErrorState(
            "Attendance already exists for this date",
          ));

          // Restore previous data
          if (_cachedAttendance != null) {
            emit(AttendanceLoadedState(_cachedAttendance!));
          }
        }
        else {
          emit(const AttendanceErrorState("Failed to add attendance"));
          if (_cachedAttendance != null) {
            emit(AttendanceLoadedState(_cachedAttendance!));
          }
        }
      } catch (e) {
        emit(AttendanceErrorState(e.toString()));
        if (_cachedAttendance != null) {
          emit(AttendanceLoadedState(_cachedAttendance!));
        }
      }
    });

    on<UpdateAttendanceEvent>((event, emit) async {
      // Silent loading - maintain current state
      if (state is AttendanceLoadedState) {
        emit(AttendanceSilentLoadingState(
           (state as AttendanceLoadedState).attendance
        ));
      }

      try {
        final res = await _repo.updateAttendance(newData: event.newData);
        final msg = res["msg"];

        if (msg == "success") {
          // Reload with silent loading
          add(LoadAllAttendanceEvent(date: _currentDate));
        } else {
          emit(AttendanceErrorState("Failed to update attendance"));
          if (_cachedAttendance != null) {
            emit(AttendanceLoadedState(_cachedAttendance!));
          }
        }
      } catch (e) {
        emit(AttendanceErrorState(e.toString()));
        if (_cachedAttendance != null) {
          emit(AttendanceLoadedState(_cachedAttendance!));
        }
      }
    });
  }
}