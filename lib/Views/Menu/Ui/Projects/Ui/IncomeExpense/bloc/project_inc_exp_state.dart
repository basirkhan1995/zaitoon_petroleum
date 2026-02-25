part of 'project_inc_exp_bloc.dart';

sealed class ProjectIncExpState extends Equatable {
  const ProjectIncExpState();
}

final class ProjectIncExpInitial extends ProjectIncExpState {
  @override
  List<Object> get props => [];
}

final class ProjectIncExpLoadingState extends ProjectIncExpState {
  @override
  List<Object> get props => [];
}

final class ProjectIncExpSuccessState extends ProjectIncExpState {
  @override
  List<Object> get props => [];
}

final class ProjectIncExpErrorState extends ProjectIncExpState {
  final String message;
  const ProjectIncExpErrorState(this.message);
  @override
  List<Object> get props => [message];
}

final class ProjectIncExpLoadedState extends ProjectIncExpState {
  final ProjectInOutModel inOut;
  const ProjectIncExpLoadedState(this.inOut);
  @override
  List<Object> get props => [inOut];
}

