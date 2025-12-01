part of 'fetch_atat_bloc.dart';

sealed class FetchAtatEvent extends Equatable {
  const FetchAtatEvent();
}

class FetchAccToAccEvent extends FetchAtatEvent{
  final String ref;
  const FetchAccToAccEvent(this.ref);
  @override
  List<Object?> get props => [ref];
}