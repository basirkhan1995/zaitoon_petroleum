part of 'trpt_bloc.dart';

sealed class TrptEvent extends Equatable {
  const TrptEvent();
}

class LoadTrptEvent extends TrptEvent{
  final String reference;
  const LoadTrptEvent(this.reference);
  @override
  List<Object?> get props => [reference];
}
