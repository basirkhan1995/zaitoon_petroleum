part of 'ar_ap_bloc.dart';

sealed class ArApEvent extends Equatable {
  const ArApEvent();
}

class LoadArApEvent extends ArApEvent{
  final String? name;
  final String? ccy;
  const LoadArApEvent({this.name, this.ccy});
  @override
  List<Object?> get props => [name,ccy];
}