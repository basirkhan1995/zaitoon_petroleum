part of 'services_bloc.dart';

sealed class ServicesState extends Equatable {
  const ServicesState();
}

final class ServicesInitial extends ServicesState {
  @override
  List<Object> get props => [];
}
final class ServicesLoadingState extends ServicesState {
  @override
  List<Object> get props => [];
}

final class ServicesSuccessState extends ServicesState {
  @override
  List<Object> get props => [];
}

final class ServicesErrorState extends ServicesState {
  final String message;
  const ServicesErrorState(this.message);
  @override
  List<Object> get props => [message];
}

final class ServicesLoadedState extends ServicesState {
  final List<ServicesModel> services;
  const ServicesLoadedState(this.services);
  @override
  List<Object> get props => [services];
}


