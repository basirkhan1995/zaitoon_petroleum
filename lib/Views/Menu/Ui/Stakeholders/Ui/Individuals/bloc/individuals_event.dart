part of 'individuals_bloc.dart';

sealed class IndividualsEvent extends Equatable {
  const IndividualsEvent();
}

class LoadIndividualsEvent extends IndividualsEvent{
  final int? indId;
  const LoadIndividualsEvent({this.indId});
  @override
  List<Object?> get props => [];
}