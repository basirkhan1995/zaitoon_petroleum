part of 'glat_bloc.dart';

sealed class GlatState extends Equatable {
  const GlatState();
}

final class GlatInitial extends GlatState {
  @override
  List<Object> get props => [];
}

final class GlatLoadingState extends GlatState {
  @override
  List<Object> get props => [];
}

final class GlatErrorState extends GlatState {
  final String message;
  const GlatErrorState(this.message);
  @override
  List<Object> get props => [message];
}

final class GlatLoadedState extends GlatState {
  final GlatModel data;

  const GlatLoadedState(this.data);

  @override
  List<Object?> get props => [data];
}
