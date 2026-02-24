import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'project_services_event.dart';
part 'project_services_state.dart';

class ProjectServicesBloc extends Bloc<ProjectServicesEvent, ProjectServicesState> {
  ProjectServicesBloc() : super(ProjectServicesInitial()) {
    on<ProjectServicesEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
