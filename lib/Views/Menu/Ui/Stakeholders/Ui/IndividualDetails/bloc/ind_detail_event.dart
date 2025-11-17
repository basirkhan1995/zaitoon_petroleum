part of 'ind_detail_bloc.dart';

sealed class IndDetailTabEvent extends Equatable {
  const IndDetailTabEvent();
}

class IndOnChangedEvent extends IndDetailTabEvent{
  final IndividualDetailTabName tab;
  const IndOnChangedEvent(this.tab);
  @override
  List<Object?> get props => [tab];
}