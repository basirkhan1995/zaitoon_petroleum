import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'projects_report_event.dart';
part 'projects_report_state.dart';

class ProjectsReportBloc extends Bloc<ProjectsReportEvent, ProjectsReportState> {
  ProjectsReportBloc() : super(ProjectsReportInitial()) {
    on<ProjectsReportEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
