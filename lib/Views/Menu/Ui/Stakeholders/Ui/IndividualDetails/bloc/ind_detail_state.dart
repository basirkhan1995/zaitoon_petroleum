part of 'ind_detail_bloc.dart';

enum IndividualDetailTabName {accounts, users}

class IndividualDetailTabState extends Equatable {
  final IndividualDetailTabName tab;
  const IndividualDetailTabState({this.tab = IndividualDetailTabName.accounts});
  @override
  List<Object> get props => [tab];
}
