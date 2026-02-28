part of 'projects_by_id_bloc.dart';

sealed class ProjectsByIdEvent extends Equatable {
  const ProjectsByIdEvent();
}

class LoadProjectByIdEvent extends ProjectsByIdEvent{
  final int prjId;
  const LoadProjectByIdEvent(this.prjId);
  @override
  List<Object?> get props => [prjId];
}

class ResetProjectByIdEvent extends ProjectsByIdEvent{
  const ResetProjectByIdEvent();
  @override
  List<Object?> get props => [];
}