part of 'projects_report_bloc.dart';

sealed class ProjectsReportState extends Equatable {
  const ProjectsReportState();
}

final class ProjectsReportInitial extends ProjectsReportState {
  @override
  List<Object> get props => [];
}
