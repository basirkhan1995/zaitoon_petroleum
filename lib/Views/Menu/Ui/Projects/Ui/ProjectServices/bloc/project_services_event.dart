part of 'project_services_bloc.dart';

sealed class ProjectServicesEvent extends Equatable {
  const ProjectServicesEvent();
}

class LoadProjectServiceEvent extends ProjectServicesEvent{
  final int projectId;
  const LoadProjectServiceEvent(this.projectId);
  @override
  List<Object?> get props => [projectId];
}

class DeleteProjectServiceEvent extends ProjectServicesEvent{
  final int pjdId;
  final int projectId;
  final String usrName;
  const DeleteProjectServiceEvent(this.pjdId,this.projectId, this.usrName);
  @override
  List<Object?> get props => [pjdId,projectId, usrName];
}

class AddProjectServiceEvent extends ProjectServicesEvent{
  final ProjectServicesModel newService;
  const AddProjectServiceEvent(this.newService);
  @override
  List<Object?> get props => [newService];
}

class UpdateProjectServiceEvent extends ProjectServicesEvent{
  final ProjectServicesModel newService;
  const UpdateProjectServiceEvent(this.newService);
  @override
  List<Object?> get props => [newService];
}

