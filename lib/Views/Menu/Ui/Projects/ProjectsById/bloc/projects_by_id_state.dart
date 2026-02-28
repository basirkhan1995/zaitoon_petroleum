part of 'projects_by_id_bloc.dart';

sealed class ProjectsByIdState extends Equatable {
  const ProjectsByIdState();
}

final class ProjectsByIdInitial extends ProjectsByIdState {
  @override
  List<Object> get props => [];
}

final class ProjectByIdLoadingState extends ProjectsByIdState{
  @override
  List<Object?> get props => [];
}

final class ProjectByIdErrorState extends ProjectsByIdState{
  final String message;
  const ProjectByIdErrorState(this.message);
  @override
  List<Object?> get props => [message];
}


final class ProjectByIdLoadedState extends ProjectsByIdState{
  final ProjectByIdModel project;
  const ProjectByIdLoadedState(this.project);
  @override
  List<Object?> get props => [project];
}