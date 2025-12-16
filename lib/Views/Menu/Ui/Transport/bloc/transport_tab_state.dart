part of 'transport_tab_bloc.dart';

enum TransportTabName {drivers, vehicles, shipping}

class TransportTabState extends Equatable {
  final TransportTabName tab;
  const TransportTabState({this.tab = TransportTabName.shipping});
  @override
  List<Object> get props => [tab];
}
