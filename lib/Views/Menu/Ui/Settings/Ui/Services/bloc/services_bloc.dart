import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:zaitoon_petroleum/Services/repositories.dart';
import 'package:zaitoon_petroleum/Views/Menu/Ui/Settings/Ui/Services/model/services_model.dart';

part 'services_event.dart';
part 'services_state.dart';

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  final Repositories _repo;
  ServicesBloc(this._repo) : super(ServicesInitial()) {

    on<LoadProjectServicesEvent>((event, emit)async {
      emit(ProjectServicesLoadingState());
      try{
        final pjr = await _repo.getServices();
        emit(ProjectServicesLoadedState(pjr));
      }catch(e){
        emit(ProjectServicesErrorState(e.toString()));
      }
    });
    on<AddProjectServicesEvent>((event, emit)async {
      emit(ProjectServicesLoadingState());
      try{
        final res = await _repo.addService(newData: event.newData);
        final response = res['msg'];
        if(response == "success"){
          emit(ProjectServicesSuccessState());
          add(LoadProjectServicesEvent());
        }else{
          emit(ProjectServicesErrorState(response));
        }
      }catch(e){
        emit(ProjectServicesErrorState(e.toString()));
      }
    });
    on<UpdateProjectServicesEvent>((event, emit)async {
      emit(ProjectServicesLoadingState());
      try{
        final res = await _repo.updateService(newData: event.newData);
        final response = res['msg'];
        if(response == "success"){
          emit(ProjectServicesSuccessState());
          add(LoadProjectServicesEvent());
        }else{
          emit(ProjectServicesErrorState(response));
        }
      }catch(e){
        emit(ProjectServicesErrorState(e.toString()));
      }
    });
    on<DeleteProjectServicesEvent>((event, emit)async {
      emit(ProjectServicesLoadingState());
      try{
        final res = await _repo.deleteProject(projectId: event.pjrId,usrName: event.usrName);
        final response = res['msg'];
        if(response == "success"){
          emit(ProjectServicesSuccessState());
          add(LoadProjectServicesEvent());
        }else{
          emit(ProjectServicesErrorState(response));
        }
      }catch(e){
        emit(ProjectServicesErrorState(e.toString()));
      }
    });

  }
}
