part of 'project_services_bloc.dart';

sealed class ProjectServicesState extends Equatable {
  const ProjectServicesState();
}

final class ProjectServicesInitial extends ProjectServicesState {
  @override
  List<Object> get props => [];
}
