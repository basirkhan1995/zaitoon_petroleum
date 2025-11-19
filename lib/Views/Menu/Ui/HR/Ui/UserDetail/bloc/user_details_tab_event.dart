part of 'user_details_tab_bloc.dart';

sealed class UserDetailsTabEvent extends Equatable {
  const UserDetailsTabEvent();
}
class UserDetailsTabOnChangedEvent extends UserDetailsTabEvent{
  final UserDetailsTabNames tab;
  const UserDetailsTabOnChangedEvent(this.tab);
  @override
  List<Object?> get props => [tab];
}