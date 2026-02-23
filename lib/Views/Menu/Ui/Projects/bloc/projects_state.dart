part of 'projects_bloc.dart';

sealed class ProjectsState extends Equatable {
  const ProjectsState();
}

final class ProjectsInitial extends ProjectsState {
  @override
  List<Object> get props => [];
}
