part of 'user_details_tab_bloc.dart';

sealed class UserDetailsTabState extends Equatable {
  const UserDetailsTabState();
}

final class UserDetailsTabInitial extends UserDetailsTabState {
  @override
  List<Object> get props => [];
}
