part of 'user_details_tab_bloc.dart';

enum UserDetailsTabNames {overview, permissions, usrLog}

class UserDetailsTabState extends Equatable {
  final UserDetailsTabNames tab;
  const UserDetailsTabState({this.tab = UserDetailsTabNames.overview});
  @override
  List<Object> get props => [tab];
}
