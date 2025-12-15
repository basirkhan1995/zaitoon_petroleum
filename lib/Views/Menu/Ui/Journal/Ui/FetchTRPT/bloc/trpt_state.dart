part of 'trpt_bloc.dart';

sealed class TrptState extends Equatable {
  const TrptState();
}

final class TrptInitial extends TrptState {
  @override
  List<Object> get props => [];
}

final class TrptLoadingState extends TrptState {
  @override
  List<Object> get props => [];
}


final class TrptErrorState extends TrptState {
  final String error;
  const TrptErrorState(this.error);
  @override
  List<Object> get props => [error];
}


final class TrptLoadedState extends TrptState {
  final TrptModel trpt;
  const TrptLoadedState(this.trpt);
  @override
  List<Object> get props => [trpt];
}
