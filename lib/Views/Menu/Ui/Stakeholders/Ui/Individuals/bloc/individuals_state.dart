part of 'individuals_bloc.dart';

sealed class IndividualsState extends Equatable {
  const IndividualsState();
}

final class IndividualsInitial extends IndividualsState {
  @override
  List<Object> get props => [];
}

final class IndividualLoadingState extends IndividualsState {
  @override
  List<Object> get props => [];
}

final class IndividualErrorState extends IndividualsState {
  final String message;
  const IndividualErrorState(this.message);
  @override
  List<Object> get props => [message];
}

final class IndividualLoadedState extends IndividualsState {
  final List<StakeholdersModel> individuals;
  const IndividualLoadedState(this.individuals);
  @override
  List<Object> get props => [individuals];
}


