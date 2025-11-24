part of 'transport_tab_bloc.dart';

sealed class TransportTabEvent extends Equatable {
  const TransportTabEvent();
}

class TransportOnChangedEvent extends TransportTabEvent{
  final TransportTabName tab;
  const TransportOnChangedEvent(this.tab);
  @override
  List<Object?> get props => [tab];
}