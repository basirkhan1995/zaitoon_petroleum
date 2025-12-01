part of 'fetch_atat_bloc.dart';

sealed class FetchAtatState extends Equatable {
  const FetchAtatState();
}

final class FetchAtatInitial extends FetchAtatState {
  @override
  List<Object> get props => [];
}

final class FetchATATLoadingState extends FetchAtatState {
  @override
  List<Object> get props => [];
}

final class FetchATATErrorState extends FetchAtatState {
  final String message;
  const FetchATATErrorState(this.message);
  @override
  List<Object> get props => [message];
}

final class FetchATATLoadedState extends FetchAtatState {
  final FetchAtatModel atat;
  const FetchATATLoadedState(this.atat);
  @override
  List<Object> get props => [atat];
}

