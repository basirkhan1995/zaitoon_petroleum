import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Attendance/model/attendance_model.dart';

part 'attendance_event.dart';
part 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final Repositories _repo;
  AttendanceBloc(this._repo) : super(AttendanceInitial()) {
    on<LoadAllAttendanceEvent>((event, emit) async{
      emit(AttendanceLoadingState());
      try{
        final res = await _repo.getAllAttendance(date: event.date);
        emit(AttendanceLoadedState(res));
      }catch(e){
       emit(AttendanceErrorState(e.toString()));
      }
    });
    on<AddAttendanceEvent>((event, emit) async{
      emit(AttendanceLoadingState());
      try{
       final res = await _repo.addNewAttendance(newData: event.newData);
       final msg = res["msg"];
       if(msg == "success"){
          add(LoadAllAttendanceEvent());

       }
      }catch(e){
        emit(AttendanceErrorState(e.toString()));
      }
    });
    on<UpdateAttendanceEvent>((event, emit) async{
      emit(AttendanceLoadingState());
      try{
        final res = await _repo.updateAttendance(newData: event.newData);
        final msg = res["msg"];
        if(msg == "success"){
          add(LoadAllAttendanceEvent());
        }
      }catch(e){
        emit(AttendanceErrorState(e.toString()));
      }
    });
  }
}
