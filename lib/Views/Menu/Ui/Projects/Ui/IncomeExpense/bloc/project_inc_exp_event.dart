part of 'project_inc_exp_bloc.dart';

sealed class ProjectIncExpEvent extends Equatable {
  const ProjectIncExpEvent();
}


class LoadProjectIncExpEvent extends ProjectIncExpEvent{
  final int projectId;
  const LoadProjectIncExpEvent(this.projectId);
  @override
  List<Object?> get props => [projectId];
}

class AddProjectIncExpEvent extends ProjectIncExpEvent{
  final ProjectInOutModel newData;
  const AddProjectIncExpEvent(this.newData);
  @override
  List<Object?> get props => [newData];
}

class UpdateProjectIncExpEvent extends ProjectIncExpEvent{
  final ProjectInOutModel newData;
  const UpdateProjectIncExpEvent(this.newData);
  @override
  List<Object?> get props => [newData];
}