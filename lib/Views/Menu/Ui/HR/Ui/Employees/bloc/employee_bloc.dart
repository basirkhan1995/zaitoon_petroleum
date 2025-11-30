import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/HR/Ui/Employees/model/emp_model.dart';

part 'employee_event.dart';
part 'employee_state.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final Repositories _repo;
  EmployeeBloc(this._repo) : super(EmployeeInitial()) {

    on<LoadEmployeeEvent>((event, emit)async {
      emit(EmployeeLoadingState());
     try{
      final emp = await _repo.getEmployees(empId: event.empId);
      emit(EmployeeLoadedState(emp));
     }catch(e){
       emit(EmployeeErrorState(e.toString()));
     }
    });
    on<AddEmployeeEvent>((event, emit) async{
      emit(EmployeeLoadingState());
       try{
        final response = await _repo.addEmployee(newEmployee: event.newEmployee);
        final msg = response['msg'];
        print(msg);
        if(msg == "success"){
          emit(EmployeeSuccessState());
          add(LoadEmployeeEvent());
        }else{
          emit(EmployeeErrorState(msg));
        }
       }catch(e){
         emit(EmployeeErrorState(e.toString()));
       }
    });

  }
}
