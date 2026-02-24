import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'project_inc_exp_event.dart';
part 'project_inc_exp_state.dart';

class ProjectIncExpBloc extends Bloc<ProjectIncExpEvent, ProjectIncExpState> {
  ProjectIncExpBloc() : super(ProjectIncExpInitial()) {
    on<ProjectIncExpEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
