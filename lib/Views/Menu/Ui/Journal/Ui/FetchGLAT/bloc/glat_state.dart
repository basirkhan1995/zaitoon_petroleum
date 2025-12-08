part of 'glat_bloc.dart';

sealed class GlatState extends Equatable {
  const GlatState();
}

final class GlatInitial extends GlatState {
  @override
  List<Object> get props => [];
}
