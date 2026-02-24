part of 'project_tabs_bloc.dart';

enum ProjectTabsName{overview,services,incomeExpense}

final class ProjectTabsState extends Equatable {
  final ProjectTabsName tabs;
  const ProjectTabsState({this.tabs = ProjectTabsName.overview});
  @override
  List<Object> get props => [tabs];
}
