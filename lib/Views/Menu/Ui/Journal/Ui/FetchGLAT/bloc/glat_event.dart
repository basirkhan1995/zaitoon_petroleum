part of 'glat_bloc.dart';

sealed class GlatEvent extends Equatable {
  const GlatEvent();
}

class LoadGlatEvent extends GlatEvent{
  final String refNumber;
  const LoadGlatEvent(this.refNumber);
  @override
  List<Object?> get props => [refNumber];
}