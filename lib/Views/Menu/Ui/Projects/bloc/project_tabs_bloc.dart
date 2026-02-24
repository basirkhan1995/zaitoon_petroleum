import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'project_tabs_event.dart';
part 'project_tabs_state.dart';

class ProjectTabsBloc extends Bloc<ProjectTabsEvent, ProjectTabsState> {
  ProjectTabsBloc() : super(ProjectTabsState(tabs: ProjectTabsName.overview)) {
    on<ProjectTabOnChangedEvent>((event, emit) {
      emit(ProjectTabsState(tabs: event.tabs));
    });
  }
}
