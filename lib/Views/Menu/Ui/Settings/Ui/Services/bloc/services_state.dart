part of 'services_bloc.dart';

sealed class ServicesState extends Equatable {
  const ServicesState();
}

final class ServicesInitial extends ServicesState {
  @override
  List<Object> get props => [];
}
