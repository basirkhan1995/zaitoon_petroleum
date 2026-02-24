part of 'project_tabs_bloc.dart';

sealed class ProjectTabsEvent extends Equatable {
  const ProjectTabsEvent();
}
class ProjectTabOnChangedEvent extends ProjectTabsEvent{
  final ProjectTabsName tabs;
  const ProjectTabOnChangedEvent(this.tabs);
  @override
  List<Object?> get props => [tabs];
}