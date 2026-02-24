part of 'services_bloc.dart';

sealed class ServicesState extends Equatable {
  const ServicesState();
}

final class ServicesInitial extends ServicesState {
  @override
  List<Object> get props => [];
}
final class ProjectServicesLoadingState extends ServicesState {
  @override
  List<Object> get props => [];
}

final class ProjectServicesSuccessState extends ServicesState {
  @override
  List<Object> get props => [];
}

final class ProjectServicesErrorState extends ServicesState {
  final String message;
  const ProjectServicesErrorState(this.message);
  @override
  List<Object> get props => [message];
}

final class ProjectServicesLoadedState extends ServicesState {
  final List<ServicesModel> services;
  const ProjectServicesLoadedState(this.services);
  @override
  List<Object> get props => [services];
}


