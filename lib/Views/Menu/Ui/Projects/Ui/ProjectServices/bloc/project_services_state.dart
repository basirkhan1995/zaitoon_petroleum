part of 'project_services_bloc.dart';

sealed class ProjectServicesState extends Equatable {
  const ProjectServicesState();
}

final class ProjectServicesInitial extends ProjectServicesState {
  @override
  List<Object> get props => [];
}

final class ProjectServicesLoadingState extends ProjectServicesState {
  @override
  List<Object> get props => [];
}

final class ProjectServicesSuccessState extends ProjectServicesState {
  @override
  List<Object> get props => [];
}

final class ProjectServicesErrorState extends ProjectServicesState {
  final String message;
  const ProjectServicesErrorState(this.message);
  @override
  List<Object> get props => [message];
}

final class ProjectServicesLoadedState extends ProjectServicesState {
  final List<ProjectServicesModel> projectServices;
  const ProjectServicesLoadedState(this.projectServices);
  @override
  List<Object> get props => [projectServices];
}
