part of 'pro_cat_bloc.dart';

sealed class ProCatEvent extends Equatable {
  const ProCatEvent();
}

class LoadProCatEvent extends ProCatEvent{
  final int? catId;
  const LoadProCatEvent({this.catId});
  @override
  List<Object?> get props => [];
}