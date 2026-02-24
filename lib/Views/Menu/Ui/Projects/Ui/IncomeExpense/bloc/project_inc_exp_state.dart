part of 'project_inc_exp_bloc.dart';

sealed class ProjectIncExpState extends Equatable {
  const ProjectIncExpState();
}

final class ProjectIncExpInitial extends ProjectIncExpState {
  @override
  List<Object> get props => [];
}
